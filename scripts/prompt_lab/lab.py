#!/usr/bin/env python3
"""Compare tutor prompts and models over a scripted conversation.

Usage:
    python3 scripts/prompt_lab/lab.py EXPERIMENT.json [--out DIR] [--only LABEL ...]

Each setup in the experiment plays the whole conversation, using its own replies as history,
streamed the way the app streams. Per turn it records time to first token, time to the first
character of conversation.content, token use and the parsed reply. A judge model then rates the
CEFR level of each setup's replies. See README.md next to this file for the experiment format.

Talks to any OpenAI-compatible /chat/completions endpoint. Standard library only.
"""

import argparse
import datetime
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
USER_SPLIT = '\n=== USER ===\n'
JUDGE_PROMPT = (
    'Rate the CEFR level (A1, A2, B1, B2, C1 or C2) a learner needs to understand these '
    '{target_language} tutor replies, judging vocabulary, grammar and sentence length. '
    'Answer with the level only.\n\n{replies}'
)


def load_json(path):
    return json.loads(Path(path).read_text())


def strict(schema):
    """Adds additionalProperties: false to every object, as strict json_schema mode requires."""
    if isinstance(schema, dict):
        schema = {k: strict(v) for k, v in schema.items()}
        if schema.get('type') == 'object':
            schema['additionalProperties'] = False
        return schema
    if isinstance(schema, list):
        return [strict(v) for v in schema]
    return schema


class Experiment:
    """An experiment file, with every path in it resolved against the file's own folder."""

    def __init__(self, path):
        self.path = Path(path).resolve()
        spec = load_json(self.path)
        base = self.path.parent
        resolve = lambda p: (base / p).resolve()
        self.providers = spec['providers']
        self.models = spec['models']
        self.compare = spec['compare']
        self.prompts = {name: resolve(p).read_text() for name, p in spec['prompts'].items()}
        self.schema = strict(load_json(resolve(spec['schema'])))
        self.conversation = load_json(resolve(spec['conversation']))
        self.variables = spec.get('variables', {})
        self.tables = {name: load_json(resolve(p)) if isinstance(p, str) else p
                       for name, p in spec.get('tables', {}).items()}
        self.optional = set(spec.get('optional_variables', []))
        self.setups = spec['setups']
        self.judge = spec.get('judge')
        self.defaults = spec.get('request', {'max_completion_tokens': 512})

    def fill(self, setup, message, history):
        """Substitutes the template. A table variable looks its value up by another variable."""
        values = {**self.variables, **setup.get('vars', {}),
                  'user_message': message, 'conversation_history': '\n'.join(history)}
        for name, table in self.tables.items():
            key = values.get(table['by'], '')
            value = table['values'].get(key, '')
            values[name] = '\n'.join(f'  - {v}' for v in value) if isinstance(value, list) else value
        text = self.prompts[setup['prompt']]
        lines = []
        for line in text.split('\n'):
            names = re.findall(r'\{\{(\w+)\}\}', line)
            if any(n in self.optional and not values.get(n) for n in names):
                continue
            lines.append(line)
        text = '\n'.join(lines)
        for name, value in values.items():
            text = text.replace('{{' + name + '}}', str(value))
        left = re.findall(r'\{\{\w+\}\}', text)
        if left:
            raise ValueError(f"setup {setup['prompt']}: unsubstituted {sorted(set(left))}")
        return text


def post(provider, body):
    headers = {'Content-Type': 'application/json'}
    key_env = provider.get('api_key_env')
    if key_env and os.environ.get(key_env):
        headers['Authorization'] = 'Bearer ' + os.environ[key_env]
    request = urllib.request.Request(provider['base_url'].rstrip('/') + '/chat/completions',
                                     json.dumps(body).encode(), headers)
    return urllib.request.urlopen(request, timeout=180)


def messages_for(prompt_text):
    developer, _, user = prompt_text.partition(USER_SPLIT)
    if not user:
        return [{'role': 'user', 'content': prompt_text}]
    return [{'role': 'developer', 'content': developer}, {'role': 'user', 'content': user}]


def turn(exp, model_label, setup, prompt_text):
    model = exp.models[model_label]
    body = {
        'model': model['model'], 'messages': messages_for(prompt_text), 'stream': True,
        'stream_options': {'include_usage': True},
        'response_format': {'type': 'json_schema',
                            'json_schema': {'name': 'tutor_response', 'strict': True, 'schema': exp.schema}},
        **exp.defaults, **model.get('params', {}), **setup.get('params', {}),
    }
    start = time.time()
    first = reply_start = None
    buffer, usage = '', {}
    with post(exp.providers[model['provider']], body) as response:
        for raw in response:
            line = raw.decode().strip()
            if not line.startswith('data: ') or line == 'data: [DONE]':
                continue
            event = json.loads(line[6:])
            usage = event.get('usage') or usage
            for choice in event.get('choices', []):
                delta = (choice.get('delta') or {}).get('content')
                if delta:
                    first = first or time.time() - start
                    buffer += delta
                    if reply_start is None and re.search(
                            r'"conversation"\s*:\s*\{\s*"content"\s*:\s*"[^"]', buffer):
                        reply_start = time.time() - start
    return {'ttft': first, 'reply_start': reply_start, 'total': time.time() - start,
            'usage': usage, 'response': json.loads(buffer)}


def run_setup(exp, model_label, setup):
    history, turns = [], []
    try:
        for message in exp.conversation:
            history.append(f'User: {message}')
            result = turn(exp, model_label, setup, exp.fill(setup, message, history))
            history.append(f"Tutor: {result['response']['conversation']['content']}")
            turns.append({'user': message, **result})
    except urllib.error.HTTPError as e:
        return {'model': model_label, 'setup': setup, 'error': e.read().decode()[:400], 'turns': turns}
    return {'model': model_label, 'setup': setup, 'turns': turns}


def judge(exp, run):
    if not exp.judge or run.get('error'):
        return None
    model = exp.models[exp.judge['model']]
    replies = '\n'.join(f"- {t['response']['conversation']['content']}" for t in run['turns'])
    ask = exp.judge.get('prompt', JUDGE_PROMPT).format(
        target_language=exp.variables.get('target_language', ''), replies=replies)
    body = {'model': model['model'], 'messages': [{'role': 'user', 'content': ask}],
            **exp.judge.get('params', {})}
    with post(exp.providers[model['provider']], body) as response:
        return json.load(response)['choices'][0]['message']['content'].strip()


def metrics(run):
    """Numbers per setup. 'invented' is an error whose original is not in the learner's message;
    'no-op' one whose corrected equals its original."""
    turns = run['turns']
    replies = [t['response']['conversation']['content'] for t in turns]
    errors = [(t, e) for t in turns for e in t['response']['correction']['errors']]
    words = sum(len(r.split()) for r in replies)
    sentences = sum(max(1, len([s for s in re.split(r'[.!?]+', r) if s.strip()])) for r in replies)
    quoted = [len(e['original'].split()) for _, e in errors]
    mean = lambda key: sum(t[key] or 0 for t in turns) / len(turns)
    return {
        'words_per_reply': round(words / len(turns), 1),
        'words_per_sentence': round(words / sentences, 1),
        'errors': len(errors),
        'quoted_words_mean': round(sum(quoted) / len(quoted), 1) if quoted else 0,
        'quoted_words_max': max(quoted, default=0),
        'invented': sum(1 for t, e in errors if e['original'] not in t['user']),
        'noop': sum(1 for _, e in errors if e['original'].strip().lower() == e['corrected'].strip().lower()),
        'ttft_s': round(mean('ttft'), 2),
        'reply_start_s': round(mean('reply_start'), 2),
        'total_s': round(mean('total'), 2),
        'tokens_in': sum(t['usage'].get('prompt_tokens', 0) for t in turns),
        'tokens_out': sum(t['usage'].get('completion_tokens', 0) for t in turns),
    }


def describe(setup):
    parts = [setup['prompt'], *[f'{k}={v}' for k, v in setup.get('vars', {}).items()],
             *[f'{k}={v}' for k, v in setup.get('params', {}).items()]]
    return ' '.join(parts)


def summary(exp, runs):
    lines = [f'# Prompt lab: {exp.path.name}', '',
             f"{datetime.date.today().isoformat()}, {len(exp.conversation)} turns per setup.", '',
             '| Model | Setup | Judged | Words per reply | Words per sentence | Quoted words (max) '
             '| Invented | No-op | First token | Reply starts | Tokens in / out |',
             '| -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |']
    for run in runs:
        if run.get('error'):
            lines.append(f"| {run['model']} | {describe(run['setup'])} | error: {run['error'][:80]} "
                         '| | | | | | | | |')
            continue
        m = run['metrics']
        lines.append(
            f"| {run['model']} | {describe(run['setup'])} | {run.get('judged') or ''} "
            f"| {m['words_per_reply']:.0f} | {m['words_per_sentence']} "
            f"| {m['quoted_words_mean']} ({m['quoted_words_max']}) | {m['invented']} | {m['noop']} "
            f"| {m['ttft_s']} s | {m['reply_start_s']} s | {m['tokens_in']} / {m['tokens_out']} |")
    lines += ['', '## Replies', '']
    for run in runs:
        lines.append(f"### {run['model']} | {describe(run['setup'])}")
        lines.append('')
        for t in run['turns']:
            fixes = '; '.join(f"{e['original']} -> {e['corrected']}"
                              for e in t['response']['correction']['errors'])
            lines.append(f"- User: {t['user']}")
            lines.append(f"  - Fix: {fixes or '(none)'}")
            lines.append(f"  - Tutor: {t['response']['conversation']['content']}")
        lines.append('')
    return '\n'.join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('experiment')
    parser.add_argument('--out', help='folder for results.json and summary.md (default: next to the experiment)')
    parser.add_argument('--only', nargs='*', help='model labels to run (default: all in compare)')
    args = parser.parse_args()
    exp = Experiment(args.experiment)
    jobs = [(label, setup) for setup in exp.setups
            for label in setup.get('models', exp.compare)
            if not args.only or label in args.only]
    with ThreadPoolExecutor(min(16, len(jobs))) as pool:
        runs = list(pool.map(lambda job: run_setup(exp, *job), jobs))
        judged = list(pool.map(lambda run: judge(exp, run), runs))
    for run, level in zip(runs, judged):
        run['judged'] = level
        if not run.get('error'):
            run['metrics'] = metrics(run)
    stamp = datetime.datetime.now().strftime('%Y-%m-%d_%H%M')
    out = Path(args.out) if args.out else exp.path.parent / 'results' / stamp
    out.mkdir(parents=True, exist_ok=True)
    (out / 'results.json').write_text(json.dumps(runs, ensure_ascii=False, indent=1))
    text = summary(exp, runs)
    (out / 'summary.md').write_text(text)
    print(text.split('\n## Replies')[0])
    print(f'\nWritten to {out}', file=sys.stderr)


if __name__ == '__main__':
    main()
