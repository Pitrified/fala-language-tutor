---
status: draft
priority: 0
description: |
  Make the tutor's replies fit the learner: a verbosity setting, and a CEFR level that
  actually changes how complex the reply is.
---

# Reply length and complexity

Status: note. Nothing researched or implemented.

## Where this came from

"We might want a setting for the verbosity / Cefr does not change much the actual complexity of the response" (user, 2026-09-28).

## What the code gives us today

- The prompt in use is `assets/prompts/tutor_response/v3.txt`. The level enters it twice: "The user is learning {{target_language}} at {{cefr_level}} level" and the rule "Match complexity to {{cefr_level}} level." Nothing describes what a level means, and nothing sets the length of the reply beyond "Keep your reply conversational and encouraging."
- The level is a setting on the Language page and applies to the open conversation.

## Ideas to weigh later

- A verbosity setting (short / normal / long), passed to the prompt as a length rule, such as a sentence count.
- Concrete per-level instructions in the prompt in place of the bare level name: sentence length, tenses allowed, vocabulary range, idioms or none.
- A "say it better" mode: besides the correction, the tutor suggests another way to express what the learner said, with slightly richer words or structures in line with the selected level, so a correct but plain sentence still gets something to learn from. "on top of the correction there could be a mode where the engine also suggests a similar way to express whatever the user said, using slightly more complex words, in line with the selected level" (user, 2026-09-28). It would be a new field in `TutorResponse`, empty when there is nothing to add, and a toggle.
- Measure before changing: the same conversation at A1 and at C1, with sentence length and word counts compared, to see how much the level changes today.

## Model and baseline test, 2026-09-28

Prices from OpenAI's pricing page, standard tier as read from its layout, USD per million tokens (input / output): gpt-6-luna 0.10 / 0.125, gpt-5.6-luna 0.20 / 0.25, gpt-5-nano 0.05 / 0.40, gpt-4.1-nano 0.10 / 0.40, gpt-4o-mini (the app's default) 0.15 / 0.60.

`v3.txt` sent as the app sends it (strict `tutor_response` schema, 512 tokens, temperature 0.7), pt-BR, explanations in English, two learner messages (one with three errors, one correct), at A1 and C1:

- gpt-6-luna with `reasoning_effort: none`: valid JSON, same corrections as gpt-4o-mini, 2.5 to 5 s. It rejects `minimal`; without the setting it spends hidden reasoning tokens. "gpt 6 luna looks good" (user).
- gpt-5.6-luna: rejected, it only accepts temperature 1.
- gpt-4o-mini: valid JSON, 1.1 to 3.2 s.
- Level: the reply to the message with errors was 12 words at A1 and 12 at C1 on gpt-6-luna, 12 and 16 on gpt-4o-mini. To the correct message, 11 and 21 words on gpt-6-luna, 13 and 19 on gpt-4o-mini. The C1 replies are longer, but the vocabulary and tenses are the same A2-level Portuguese in both. This agrees with the user's report that the level changes little.

Switching the default to gpt-6-luna needs `reasoning_effort: none` sent from `openai_inference_engine.dart`.

## Prompt lab, run 1, 2026-09-28

Files in `prompt_lab/`: `run.py` (reference script, not used by the app), `v4.txt` (draft prompt: correction and reply rules split, a `{{level_guide}}` with concrete limits per level, a `{{length_rule}}` per verbosity, at most one question), `guides.json` (the level guides and length rules), `conversation.json` (five learner messages, a Brazilian who moved to Lisbon, two or three errors each), and the raw results.

Each setup plays the whole conversation with its own replies as history, streamed as the app streams. A judge (gpt-5.4-mini) rates the CEFR level of each setup's five replies. "We accept that they are super close" (user): gpt-6-luna with `reasoning_effort: none` and gpt-4o-mini.

| Model | Prompt | Level | Length | Judged | Words per reply | Words per sentence | First token | Reply starts |
| -- | -- | -- | -- | -- | -- | -- | -- | -- |
| gpt-6-luna | v3 | A1 | | B1 | 19 | | | |
| gpt-4o-mini | v3 | A1 | | B1 | 19 | | | |
| gpt-6-luna | v3 | C1 | | B2 | 36 | 13.7 | 2.6 s | 4.2 s |
| gpt-4o-mini | v3 | C1 | | B2 | 24 | 9.1 | 0.9 s | 2.7 s |
| gpt-6-luna | v4 | A1 | normal | A2 | 14 | 4.6 | 2.7 s | 4.0 s |
| gpt-4o-mini | v4 | A1 | normal | A1 | 9 | 4.3 | 0.9 s | 2.1 s |
| gpt-6-luna | v4 | C1 | normal | B2 | 48 | 17.1 | 2.6 s | 4.3 s |
| gpt-4o-mini | v4 | C1 | normal | B2 | 23 | 10.5 | 0.9 s | 2.4 s |
| gpt-6-luna | v4 | B1 | short | B1 | 19 | 7.8 | 2.6 s | 4.1 s |
| gpt-4o-mini | v4 | B1 | short | B1 | 14 | 5.7 | 0.9 s | 2.6 s |
| gpt-6-luna | v4 | B1 | long | B1 | 43 | 9.3 | 2.6 s | 3.9 s |
| gpt-4o-mini | v4 | B1 | long | B1 | 33 | 6.4 | 1.1 s | 2.7 s |

"Reply starts" is when the first character of `conversation.content` arrives; the correction streams before it. Timings are one run with twelve setups in parallel, so they are a rough comparison, not a benchmark.

Read from the replies:

- v3 gives A1 and C1 the same B1 to B2 replies, as the user reported. v4 separates them: A1 replies drop to 9 to 14 words in short sentences, and the length rule works (B1 short 14 to 19 words, long 33 to 43).
- C1 is still judged B2 on both models. gpt-6-luna writes longer, richer C1 sentences; gpt-4o-mini's C1 is close to its B1.
- Corrections: gpt-6-luna found every planted error and invented none. gpt-4o-mini invented errors in several turns ("as rua" in a message without it, "atraso -> atrasam", "a sacola -> a sacola") and once corrected "não acostumei" to "não estou acostumado", which changes the meaning.
- Rule breaks: gpt-6-luna at A1 still used past tenses and "confundem"; at B1 long it asked two questions once; it writes em dashes. gpt-4o-mini at B1 long invented a persona ("Eu adoro a comida portuguesa") and asked "Qual é o seu ônibus favorito?".
- gpt-6-luna is about 1.7 s later to its first token and about 1.7 s later to the start of the reply.

## Prompt lab, run 2, 2026-09-28

Asked for: a `{{cefr_sample}}` variable filled with sample replies of the selected level only; one nano model; A1 and A2 not tuned further, since "seeing a sentence with its translation is more than enough to understand it all" in these languages (user).

- `v5.txt`: v4 plus `{{cefr_sample}}` (one or two sample replies per level, in `guides.json`, with an instruction to match their vocabulary, grammar and sentence length, not their content), a rule that each error's `original` is copied from the user's message, and a rule against invented experiences.
- gpt-5.4-nano runs with `reasoning_effort: none` and accepts temperature 0.7. gpt-5-nano does not: it only accepts temperature 1.
- The script now counts "invented" errors: an `original` that is not in the user's message. The count is rough: a correct error quoted with different capitals also counts, and 4o-mini's hits are errors repeated from the previous turn.

| Model | Prompt | Level | Guide | Judged | Words per reply | Words per sentence | Invented | First token | Reply starts |
| -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| gpt-6-luna | v4 | B1 | on | B1 | 24 | 8.7 | 0 | 1.2 s | 2.5 s |
| gpt-4o-mini | v4 | B1 | on | B1 | 14 | 5.4 | 1 | 0.7 s | 2.1 s |
| gpt-5.4-nano | v4 | B1 | on | B1 | 20 | 6.1 | 1 | 0.6 s | 1.3 s |
| gpt-6-luna | v4 | C1 | on | B2 | 45 | 15.9 | 0 | 1.2 s | 2.4 s |
| gpt-4o-mini | v4 | C1 | on | B1 | 20 | 9.3 | 1 | 1.1 s | 2.4 s |
| gpt-5.4-nano | v4 | C1 | on | C1 | 44 | 17.1 | 0 | 0.7 s | 1.3 s |
| gpt-6-luna | v5 | B1 | on | B1 | 25 | 9.5 | 0 | 1.2 s | 2.4 s |
| gpt-4o-mini | v5 | B1 | on | B1 | 17 | 6.7 | 1 | 0.9 s | 2.4 s |
| gpt-5.4-nano | v5 | B1 | on | B1 | 20 | 8.2 | 0 | 0.7 s | 1.5 s |
| gpt-6-luna | v5 | B2 | on | B2 | 47 | 16.9 | 0 | 1.2 s | 2.4 s |
| gpt-4o-mini | v5 | B2 | on | B2 | 38 | 12.7 | 0 | 0.8 s | 2.1 s |
| gpt-5.4-nano | v5 | B2 | on | B2 | 46 | 15.3 | 0 | 0.8 s | 1.6 s |
| gpt-6-luna | v5 | C1 | on | B2 | 37 | 15.6 | 0 | 1.2 s | 2.7 s |
| gpt-4o-mini | v5 | C1 | on | B2 | 33 | 11.6 | 2 | 1.0 s | 2.5 s |
| gpt-5.4-nano | v5 | C1 | on | C1 | 56 | 18.6 | 0 | 0.7 s | 1.8 s |
| gpt-6-luna | v5 | C1 | off | B2 | 48 | 15.1 | 0 | 1.1 s | 2.6 s |
| gpt-4o-mini | v5 | C1 | off | B2 | 34 | 12.3 | 0 | 0.7 s | 2.3 s |
| gpt-5.4-nano | v5 | C1 | off | B2 | 41 | 12.9 | 0 | 0.7 s | 1.7 s |

Mean per turn over the run, at the prices above: gpt-6-luna 783 tokens in and 266 out, about $0.0001; gpt-4o-mini 764 and 256, about $0.0003; gpt-5.4-nano 788 and 242, about $0.0005.

Read from the replies:

- B1 and B2 come out as asked on every model with v5. C1 is judged C1 only on gpt-5.4-nano; gpt-6-luna and gpt-4o-mini stay at B2.
- Samples alone (guide off) do not reach C1 on any model; guide and samples together do on gpt-5.4-nano.
- gpt-6-luna's first token came 1.2 s after the request, against 2.6 s in run 1. The difference between runs is as large as the difference between models, so timings need more runs before they decide anything.
- gpt-5.4-nano is the fastest to start the reply, and its C1 is the most natural ("uma baita confusão", "pontos fixos na rotina"). It skipped the first message's errors twice ("mudei pra", "não acostumei", both common in spoken Brazilian Portuguese), and it sometimes quotes a whole sentence as the `original`.
- gpt-4o-mini still repeats errors from earlier turns despite the new rule.

## Open questions

- Q1: Is verbosity a separate setting, or tied to the level?
  ANS: ...
- Q2: Does the "say it better" suggestion show for every message, or only when the learner's message had no errors?
  ANS: a setting decides. On, it comes with every reply automatically. Off, a button beside the reply bubble asks for it on demand: "The user has a setting to toggle, to turn it on every time automatically, or when not set, show it by pressing a button on the side of the response message bubble." (user, 2026-09-28). Consequence to design for: on demand means a second request to the model after the reply, with the learner's message and the level, while the automatic mode can ride in the same structured response.
