---
status: in progress
priority: 0
description: |
  Make the tutor's replies fit the learner: a verbosity setting, and a CEFR level that
  actually changes how complex the reply is.
---

# Reply length and complexity

Status: prompt and models compared in `prompt_lab/` (runs 1 to 4 below); phases in `tracking.md`.

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

## Prompt lab, run 3, 2026-09-28

Asked for: let the tutor play a person ("the tutor is faking a conversation, keeping the chitchat going is ok, it needs to pretend something", user); reasoning one step up where a model has it; a prompt line against quoting whole sentences; C2 "just for fun"; and a check of the prompt against OpenAI's prompting guidance.

OpenAI's guidance, read on 2026-09-28 ([prompt engineering](https://developers.openai.com/api/docs/guides/prompt-engineering), [latest model](https://developers.openai.com/api/docs/guides/latest-model), [GPT-5 prompting guide](https://developers.openai.com/cookbook/examples/gpt-5/gpt-5_prompting_guide)), against what v3 to v5 do:

| Guidance | v3 to v5 |
| -- | -- |
| Instructions in a `developer` message, the learner's input in the `user` message | everything in one `user` message |
| Sections in the order identity, instructions, examples, context, with Markdown headers | one block of rules, context in the middle |
| XML tags around inserted data | none |
| The schema gives the structure, the prompt gives what each field means | the prompt repeats the JSON shape and says little about each field |
| Few-shot examples of the output wanted | none until v5's samples |
| Fixed content first, for prompt caching | the level and language are in the first line; caching starts at 1024 tokens, above this prompt, so it does not apply yet |
| Non-reasoning models need precise instructions, reasoning models high-level guidance | precise, which fits `reasoning_effort: none` |

`v6.txt` follows the guidance: a developer part (identity, correction and reply instructions, level guide, samples, one correction example with short quotes) and a user part with `<topic>`, `<conversation_history>` and `<learner_message>`, split in the template at a `=== USER ===` line. It drops the no-invented-experiences rule and tells the tutor to share opinions and small stories. It also tells the model to report errors from the last message only, and to leave alone informal usage that is normal in speech.

Other findings:

- With `reasoning_effort: low`, gpt-6-luna and gpt-5.4-nano only accept the default temperature, so the `:low` setups send none.
- gpt-6-luna and gpt-5.4-nano accept an API `verbosity` parameter (low, medium, high); gpt-4o-mini accepts only medium. Not yet tested as a way to set reply length.

| Model | Prompt | Level | Judged | Words per reply | Words per sentence | Words per quoted error (max) | Invented | First token | Reply starts |
| -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| gpt-6-luna | v5 | C1 | B2 | 42 | 17.6 | 3.8 (8) | 0 | 1.5 s | 2.9 s |
| gpt-4o-mini | v5 | C1 | B2 | 30 | 10.1 | 3.5 (6) | 3 | 0.8 s | 2.4 s |
| gpt-5.4-nano | v5 | C1 | B2 | 43 | 16.5 | 4.3 (6) | 0 | 0.7 s | 1.3 s |
| gpt-6-luna:low | v5 | C1 | B2 | 49 | 18.9 | 3.5 (7) | 0 | 1.0 s | 2.2 s |
| gpt-5.4-nano:low | v5 | C1 | B2 | 45 | 17.2 | 4.8 (8) | 0 | 0.7 s | 1.7 s |
| gpt-6-luna | v6 | B1 | B1 | 32 | 9.4 | 2.6 (4) | 0 | 1.2 s | 2.0 s |
| gpt-4o-mini | v6 | B1 | B1 | 27 | 8.0 | 2.0 (4) | 2 | 0.7 s | 1.4 s |
| gpt-5.4-nano | v6 | B1 | B1 | 32 | 10.1 | 2.8 (4) | 0 | 0.8 s | 1.4 s |
| gpt-6-luna:low | v6 | B1 | B1 | 30 | 9.2 | 2.9 (5) | 0 | 1.6 s | 2.6 s |
| gpt-5.4-nano:low | v6 | B1 | B2 | 32 | 9.4 | 2.9 (5) | 0 | 0.7 s | 1.3 s |
| gpt-6-luna | v6 | C1 | B2 | 55 | 18.3 | 3.0 (5) | 0 | 1.3 s | 2.3 s |
| gpt-4o-mini | v6 | C1 | B2 | 35 | 10.2 | 1.9 (3) | 0 | 0.7 s | 1.9 s |
| gpt-5.4-nano | v6 | C1 | B2 | 59 | 21.2 | 2.4 (4) | 0 | 0.7 s | 1.3 s |
| gpt-6-luna:low | v6 | C1 | B2 | 58 | 19.4 | 2.5 (4) | 0 | 1.4 s | 2.1 s |
| gpt-5.4-nano:low | v6 | C1 | B2 | 68 | 22.5 | 3.0 (4) | 0 | 0.9 s | 1.2 s |
| gpt-6-luna | v6 | C2 | C1 | 56 | 18.8 | 3.0 (5) | 0 | 1.1 s | 2.1 s |
| gpt-4o-mini | v6 | C2 | B2 | 40 | 11.6 | 1.5 (3) | 1 | 0.8 s | 1.7 s |
| gpt-5.4-nano | v6 | C2 | C1 | 65 | 21.7 | 3.1 (5) | 0 | 0.7 s | 1.3 s |
| gpt-6-luna:low | v6 | C2 | B2 | 62 | 22.2 | 3.0 (5) | 0 | 2.1 s | 3.1 s |
| gpt-5.4-nano:low | v6 | C2 | C1 | 57 | 20.4 | 3.4 (6) | 0 | 0.7 s | 1.3 s |

Read from the replies:

- The judge is not steady between B2 and C1: gpt-5.4-nano's v5 C1 was judged C1 in run 2 and B2 here, with the same prompt. A single judged level per setup cannot separate B2 from C1; C2 setups are one step above C1 setups on the two newer models.
- v6 shortens the quoted errors (mean 2 to 3 words, max 4 or 5, against up to 8 with v5), and the reply starts sooner because the correction before it is shorter.
- v6 introduced no-op corrections, where `corrected` equals `original` ("qual eu tenho que pegar", "esqueci de levar sacola", "o que você acha?"), on gpt-5.4-nano and gpt-4o-mini. Next prompt: a line that `corrected` must differ, and the script counting them.
- The tutor now tells small stories ("Quando me mudei para uma cidade nova, passei semanas me orientando mais pelo cheiro das padarias"). gpt-4o-mini's persona is not coherent: it says "Aqui em São Paulo" in a chat about Lisbon.
- Reasoning `low` gave no visible gain in level or corrections, and gpt-6-luna got slower with it. `none` stays.
- gpt-5.4-nano at C2 writes long replies with slashes and parenthetical asides ("(tipo Moovit/Google Maps)"), chatty but fine for C2.

## Prompt lab, run 4, 2026-09-28

User notes on run 3:

- Level: "the target is what matters, so if to have c1 we need to send in a c2 prompt, then it's ok. we care about the end result". The level sent to the prompt can differ from the one the learner picked.
- No-op corrections: "we can have a sanity check on the sent correction and match it to the original text, if they are the same they are not shown to the user. while streaming they might appear, when completed they disappear".

`v7.txt` is v6 plus: `corrected` must differ from `original`, otherwise leave the error out. All setups at B2, with v7; the `:low` models are the ones from run 3 (reasoning `low`, left in the matrix). "No-op errors" counts entries where `corrected` equals `original`, ignoring case. The judge rated every setup B2 except one C1.

| Model | Length rule | API verbosity | Words per reply | No-op errors | Reply starts |
| -- | -- | -- | -- | -- | -- |
| gpt-6-luna | short |  | 29 | 0 | 2.6 s |
| gpt-4o-mini | short |  | 22 | 0 | 1.6 s |
| gpt-5.4-nano | short |  | 25 | 1 | 1.4 s |
| gpt-6-luna:low | short |  | 32 | 0 | 2.2 s |
| gpt-5.4-nano:low | short |  | 25 | 0 | 1.6 s |
| gpt-6-luna | normal |  | 53 | 0 | 2.4 s |
| gpt-4o-mini | normal |  | 39 | 0 | 1.8 s |
| gpt-5.4-nano | normal |  | 63 | 1 | 1.4 s |
| gpt-6-luna:low | normal |  | 50 | 0 | 2.7 s |
| gpt-5.4-nano:low | normal |  | 49 | 2 | 1.6 s |
| gpt-6-luna | long |  | 70 | 0 | 2.2 s |
| gpt-4o-mini | long |  | 56 | 0 | 1.8 s |
| gpt-5.4-nano | long |  | 85 | 2 | 1.5 s |
| gpt-6-luna:low | long |  | 67 | 0 | 2.2 s |
| gpt-5.4-nano:low | long |  | 79 | 0 | 1.6 s |
| gpt-6-luna |  | low | 51 | 0 | 2.6 s |
| gpt-5.4-nano |  | low | 45 | 2 | 1.4 s |
| gpt-6-luna:low |  | low | 48 | 0 | 2.4 s |
| gpt-5.4-nano:low |  | low | 47 | 2 | 1.6 s |
| gpt-6-luna |  | medium | 56 | 0 | 1.7 s |
| gpt-5.4-nano |  | medium | 69 | 1 | 1.2 s |
| gpt-6-luna:low |  | medium | 55 | 0 | 2.0 s |
| gpt-5.4-nano:low |  | medium | 62 | 0 | 1.5 s |
| gpt-6-luna |  | high | 61 | 0 | 2.1 s |
| gpt-5.4-nano |  | high | 65 | 2 | 1.5 s |
| gpt-6-luna:low |  | high | 56 | 0 | 1.8 s |
| gpt-5.4-nano:low |  | high | 68 | 2 | 1.6 s |
| gpt-6-luna | short | low | 31 | 0 | 1.9 s |
| gpt-5.4-nano | short | low | 27 | 0 | 1.4 s |
| gpt-6-luna:low | short | low | 28 | 0 | 2.5 s |
| gpt-5.4-nano:low | short | low | 26 | 0 | 1.4 s |
| gpt-6-luna | long | high | 70 | 0 | 2.0 s |
| gpt-5.4-nano | long | high | 83 | 1 | 1.5 s |
| gpt-6-luna:low | long | high | 68 | 0 | 2.7 s |
| gpt-5.4-nano:low | long | high | 97 | 0 | 1.4 s |

Read from the replies:

- The prompt's length rule sets the length: short gives 22 to 32 words, normal 39 to 63, long 56 to 97.
- The API `verbosity` parameter alone barely moves it: low 45 to 51 words, medium 55 to 69, high 56 to 68. With the rule present, the rule decides and the parameter adds nothing visible. The length rule stays, and also works on models without the parameter.
- v7's rule did not stop gpt-5.4-nano from writing no-op entries: one or two per run, used as "this part is fine" notes ("qual eu tenho que pegar", "No change needed"). gpt-6-luna and gpt-4o-mini wrote none. The app-side filter the user described handles it.
- Reasoning `low` again changed nothing visible.

## Decision after run 4, 2026-09-28

- Default model gpt-5.4-nano; the tested models offered in a dropdown on the model page with a line on how they differ: "gpt-5.4-nano is default, add the two tested model in a dropdown when picking the model with the brief explanation of the differences" (user).
- The script becomes a reusable tool, "so we can do the same models comparison in the future if we want to compare more providers" (user): `scripts/prompt_lab/`, documented in `docs/prompt-engineering.md`. This folder's `prompt_lab/experiment.json` describes the runs above in its format (v7 setups); `run.py` and `guides.json` are removed, the level guides, samples and length rules are now `level_guide.json`, `cefr_sample.json` and `length_rule.json`. A check run of the tool on gpt-5.4-nano matched run 4.

## Open questions

- Q1: Is verbosity a separate setting, or tied to the level?
  ANS: ...
- Q2: Does the "say it better" suggestion show for every message, or only when the learner's message had no errors?
  ANS: a setting decides. On, it comes with every reply automatically. Off, a button beside the reply bubble asks for it on demand: "The user has a setting to toggle, to turn it on every time automatically, or when not set, show it by pressing a button on the side of the response message bubble." (user, 2026-09-28). Consequence to design for: on demand means a second request to the model after the reply, with the learner's message and the level, while the automatic mode can ride in the same structured response.
