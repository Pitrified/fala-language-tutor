# Prompt lab

Runs tutor prompts against models over a scripted conversation and reports how each setup did. Used to choose a prompt version and a default model, and to compare other providers later.

```bash
python3 scripts/prompt_lab/lab.py scripts/prompt_lab/example/experiment.json
python3 scripts/prompt_lab/lab.py EXPERIMENT.json --only gpt-5.4-nano --out /tmp/lab
```

Standard library only. Results go to `results/<date_time>/` next to the experiment file, or to `--out`: `results.json` (every turn, raw) and `summary.md` (the table below, then every reply). `results/` is gitignored here; copy a run somewhere tracked if it matters.

## What a run does

Each setup plays every learner message of the conversation in turn. The history is built the way the app builds it (`User: ...` and `Tutor: ...` lines, the reply's `conversation.content`), from the setup's own replies, so a bad reply affects the turns after it. Requests are streamed with the app's schema in strict `json_schema` mode.

Per setup the summary gives:

| Column | Meaning |
| -- | -- |
| Judged | CEFR level a judge model gives the setup's replies taken together. One rating, noisy between neighbouring levels |
| Words per reply, per sentence | from `conversation.content` |
| Quoted words (max) | mean and largest length of an error's `original`; long quotes mean whole sentences were quoted |
| Invented | errors whose `original` is not in the learner's message, including ones only differing in case |
| No-op | errors whose `corrected` equals `original` |
| First token | time from request to the first streamed content |
| Reply starts | time to the first character of `conversation.content`, which is when the learner sees the reply begin; the correction streams before it |
| Tokens in / out | summed over the turns, for cost |

Timings vary from run to run by as much as they vary between models; compare them over several runs.

## Experiment file

JSON. Paths are relative to the experiment file.

| Key | Content |
| -- | -- |
| `providers` | name to `{base_url, api_key_env}`. Any OpenAI-compatible `/chat/completions` endpoint. When the variable is unset no key is sent, for a proxy that adds it |
| `models` | label to `{provider, model, params}`. `params` go into every request for that model, such as `reasoning_effort` or `temperature` |
| `compare` | model labels the setups run on |
| `judge` | `{model, params, prompt}`; `prompt` is optional and takes `{target_language}` and `{replies}` |
| `request` | fields added to every request, such as `max_completion_tokens` |
| `schema` | JSON schema of the reply; `additionalProperties: false` is added to every object |
| `prompts` | name to template file |
| `conversation` | file with a JSON list of learner messages |
| `variables` | template values shared by every setup |
| `tables` | variable name to a file (or inline object) `{by, values}`: the variable's value is `values[<value of the variable named by>]`; a list becomes indented `- ` lines |
| `optional_variables` | variables whose line is dropped from the template when their value is empty |
| `setups` | list of `{prompt, vars, params, models}`; `vars` add or override template values, `params` request fields, `models` narrows `compare` |

A template containing a line `=== USER ===` is sent as two messages: a `developer` message with the text above it and a `user` message with the text below. Otherwise the whole text is one `user` message. A placeholder left unsubstituted stops the run.

`example/` holds a minimal experiment on the app's current prompt.
