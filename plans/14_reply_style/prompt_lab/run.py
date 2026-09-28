"""Reference script: run the tutor prompt over a scripted conversation, several setups at once.

Kept with the reply-style plan as a record of how prompts and models were compared, not as a tool
the app depends on. The request mirrors the app's (strict tutor_response schema, streamed,
512 tokens), and the history is built the way ConversationController formats it, from each
setup's own replies.

Needs network access to api.openai.com with the key injected by the environment's proxy, or
OPENAI_API_KEY set. Usage:

    python3 run.py                      # the default matrix below
    python3 run.py --out results.json

Per turn it prints time to first token, time to the first character of conversation.content
(what the learner waits for before the reply starts to appear), total time, token use and the
reply. At the end a judge model rates the CEFR level of each setup's replies.
"""

import argparse
import json
import os
import re
import time
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

HERE = Path(__file__).parent
REPO = HERE.parents[2]
PROMPTS = {
    'v3': (REPO / 'assets/prompts/tutor_response/v3.txt').read_text(),
    'v4': (HERE / 'v4.txt').read_text(),
    'v5': (HERE / 'v5.txt').read_text(),
    'v6': (HERE / 'v6.txt').read_text(),
    'v7': (HERE / 'v7.txt').read_text(),
}
GUIDES = json.loads((HERE / 'guides.json').read_text())
CONVERSATION = json.loads((HERE / 'conversation.json').read_text())

ERR = {
    'type': 'object', 'additionalProperties': False, 'required': ['original', 'corrected', 'explanation'],
    'properties': {k: {'type': 'string'} for k in ['original', 'corrected', 'explanation']},
}
PAIR = {
    'type': 'object', 'additionalProperties': False, 'required': ['content', 'translation'],
    'properties': {'content': {'type': 'string'}, 'translation': {'type': 'string'}},
}
SCHEMA = {
    'type': 'object', 'additionalProperties': False, 'required': ['correction', 'conversation'],
    'properties': {
        'correction': {
            'type': 'object', 'additionalProperties': False, 'required': ['content', 'translation', 'errors'],
            'properties': {'content': {'type': 'string'}, 'translation': {'type': 'string'},
                           'errors': {'type': 'array', 'items': ERR}},
        },
        'conversation': PAIR,
    },
}

# Model id -> extra request fields. gpt-6-luna reasons by default; 'none' turns it off.
MODELS = {
    'gpt-6-luna': {'reasoning_effort': 'none', 'temperature': 0.7},
    'gpt-4o-mini': {'temperature': 0.7},
    'gpt-5.4-nano': {'reasoning_effort': 'none', 'temperature': 0.7},
    # One step up. With reasoning on, these models only accept the default temperature.
    'gpt-6-luna:low': {'reasoning_effort': 'low'},
    'gpt-5.4-nano:low': {'reasoning_effort': 'low'},
}
# (prompt, level, verbosity, level guide on). v3 ignores verbosity and the guide; v4 has no samples.
# A template with a '=== USER ===' line is sent as a developer message (above) and a user message.
# (prompt, level, length rule or '-' for none, level guide on, API verbosity or None). Models
# without the API verbosity parameter skip the setups that use it.
SETUPS = [
    ('v7', 'B2', 'short', True, None), ('v7', 'B2', 'normal', True, None), ('v7', 'B2', 'long', True, None),
    ('v7', 'B2', '-', True, 'low'), ('v7', 'B2', '-', True, 'medium'), ('v7', 'B2', '-', True, 'high'),
    ('v7', 'B2', 'short', True, 'low'), ('v7', 'B2', 'long', True, 'high'),
]
NO_API_VERBOSITY = {'gpt-4o-mini'}
JUDGE = 'gpt-5.4-mini'


def post(body, stream=False):
    headers = {'Content-Type': 'application/json'}
    if os.environ.get('OPENAI_API_KEY'):
        headers['Authorization'] = 'Bearer ' + os.environ['OPENAI_API_KEY']
    req = urllib.request.Request('https://api.openai.com/v1/chat/completions',
                                 json.dumps(body).encode(), headers)
    return urllib.request.urlopen(req, timeout=120)


def fill(prompt, level, verbosity, guide, message, history):
    values = {
        'target_language': 'Brazilian Portuguese', 'explanation_language': 'English',
        'cefr_level': level, 'topic': '', 'user_message': message,
        'conversation_history': '\n'.join(history),
        'level_guide': GUIDES['level_guide'][level] if guide else '',
        'cefr_sample': '\n'.join(f'  - {s}' for s in GUIDES['cefr_sample'][level]),
        'length_rule': GUIDES['length_rule'].get(verbosity, ''),
    }
    text = PROMPTS[prompt]
    if verbosity == '-':
        text = text.replace('- Length: {{length_rule}}\n', '')
    for key, value in values.items():
        text = text.replace('{{' + key + '}}', value)
    return text


def turn(model, prompt_text, api_verbosity):
    developer, _, user = prompt_text.partition('\n=== USER ===\n')
    messages = ([{'role': 'developer', 'content': developer}, {'role': 'user', 'content': user}]
                if user else [{'role': 'user', 'content': prompt_text}])
    body = {
        'model': model.split(':')[0], 'messages': messages,
        'max_completion_tokens': 512, 'stream': True, 'stream_options': {'include_usage': True},
        'response_format': {'type': 'json_schema',
                            'json_schema': {'name': 'tutor_response', 'strict': True, 'schema': SCHEMA}},
        **MODELS[model],
        **({'verbosity': api_verbosity} if api_verbosity else {}),
    }
    start = time.time()
    first = reply_start = None
    buffer, usage = '', {}
    with post(body, stream=True) as response:
        for raw in response:
            line = raw.decode().strip()
            if not line.startswith('data: ') or line == 'data: [DONE]':
                continue
            event = json.loads(line[6:])
            usage = event.get('usage') or usage
            for choice in event.get('choices', []):
                delta = choice.get('delta', {}).get('content')
                if delta:
                    first = first or time.time() - start
                    buffer += delta
                    if reply_start is None and re.search(r'"conversation"\s*:\s*\{\s*"content"\s*:\s*"[^"]', buffer):
                        reply_start = time.time() - start
    return {'ttft': first, 'reply_start': reply_start, 'total': time.time() - start,
            'usage': usage, 'response': json.loads(buffer)}


def run_setup(model, prompt, level, verbosity, guide, api_verbosity=None):
    history, turns = [], []
    for message in CONVERSATION:
        history.append(f'User: {message}')
        result = turn(model, fill(prompt, level, verbosity, guide, message, history), api_verbosity)
        history.append(f"Tutor: {result['response']['conversation']['content']}")
        turns.append({'user': message, **result})
    return {'model': model, 'prompt': prompt, 'level': level, 'verbosity': verbosity, 'guide': guide,
            'api_verbosity': api_verbosity, 'turns': turns}


def judge(replies):
    ask = ('Rate the CEFR level (A1, A2, B1, B2, C1 or C2) a learner needs to understand these '
           'Brazilian Portuguese tutor replies, judging vocabulary, grammar and sentence length. '
           'Answer with the level only.\n\n' + '\n'.join(f'- {r}' for r in replies))
    body = {'model': JUDGE, 'messages': [{'role': 'user', 'content': ask}], 'reasoning_effort': 'low'}
    with post(body) as response:
        return json.load(response)['choices'][0]['message']['content'].strip()


def words(text):
    return len(text.split())


def sentences(text):
    return max(1, len([s for s in re.split(r'[.!?]+', text) if s.strip()]))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--out', default=str(HERE / 'last.json'))
    args = parser.parse_args()
    jobs = [(m, *s) for s in SETUPS for m in MODELS
            if not (len(s) > 4 and s[4] and m.split(':')[0] in NO_API_VERBOSITY)]
    with ThreadPoolExecutor(len(jobs)) as pool:
        runs = list(pool.map(lambda job: run_setup(*job), jobs))
        levels = list(pool.map(
            lambda run: judge([t['response']['conversation']['content'] for t in run['turns']]), runs))
    for run, level in zip(runs, levels):
        run['judged_level'] = level
        replies = [t['response']['conversation']['content'] for t in run['turns']]
        n_words = sum(words(r) for r in replies)
        n_sentences = sum(sentences(r) for r in replies)
        mean = lambda key: sum(t[key] or 0 for t in run['turns']) / len(run['turns'])
        invented = sum(1 for t in run['turns'] for e in t['response']['correction']['errors']
                       if e['original'] not in t['user'])
        noop = sum(1 for t in run['turns'] for e in t['response']['correction']['errors']
                   if e['original'].strip().lower() == e['corrected'].strip().lower())
        out_tokens = sum(t['usage'].get('completion_tokens', 0) for t in run['turns'])
        print(f"\n## {run['model']} | {run['prompt']} | {run['level']} | {run['verbosity']} "
              f"| judged {level} | {n_words / len(replies):.0f} words/reply "
              f"| guide {'on' if run['guide'] else 'off'} | api {run['api_verbosity']} | invented {invented} | no-op {noop} "
              f"| {n_words / n_sentences:.1f} words/sentence | ttft {mean('ttft'):.2f}s "
              f"| reply starts {mean('reply_start'):.2f}s | total {mean('total'):.2f}s | out {out_tokens} tok")
        for t in run['turns']:
            errors = '; '.join(f"{e['original']} -> {e['corrected']}" for e in t['response']['correction']['errors'])
            print(f"   fix : {errors or '(none)'}")
            print(f"   say : {t['response']['conversation']['content']}")
    Path(args.out).write_text(json.dumps(runs, ensure_ascii=False, indent=1))


if __name__ == '__main__':
    main()
