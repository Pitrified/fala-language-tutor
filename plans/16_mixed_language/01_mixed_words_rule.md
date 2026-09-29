---
status: done
---

# 01 - Mixed-in words rule and the Spanish run

## Prompt lab run 1, 2026-09-29

`prompt_lab/experiment.json`, results in `prompt_lab/results/run1/`. v5 is the app's prompt before this phase; v6 adds to the correction rules: words from another language are errors, blends and false friends included, among the most important, corrected with the target word and the source language named.

| Model | Prompt | Conversation | Level | Caught | Explanations naming the language |
| -- | -- | -- | -- | -- | -- |
| gpt-5.4-nano | v5 | mixed Portuguese | B1 | 5 / 8 | 2 / 5 |
| gpt-5.4-nano | v6 | mixed Portuguese | B1 | 7 / 8 | 3 / 7 |
| gpt-6-luna | v5 | mixed Portuguese | B1 | 8 / 8 | 3 / 7 |
| gpt-6-luna | v6 | mixed Portuguese | B1 | 8 / 8 | 5 / 7 |
| gpt-5.4-nano | v5 | Spanish | B1 | 5 / 7 | 0 / 6 |
| gpt-5.4-nano | v6 | Spanish | B1 | 6 / 7 | 1 / 6 |
| gpt-5.4-nano | v6 | Spanish | C1 | 6 / 7 | 1 / 6 |
| gpt-6-luna | v5 | Spanish | B1 | 7 / 7 | 2 / 7 |
| gpt-6-luna | v6 | Spanish | B1 | 7 / 7 | 4 / 7 |
| gpt-6-luna | v6 | Spanish | C1 | 7 / 7 | 4 / 7 |

- The user's sentence: v5 on gpt-5.4-nano corrected "perigolos" as a spelling error and left "verso"; v6 quoted both ("sem dúvida verso -> sem dúvida em direção"). gpt-6-luna replaced "verso o perigolos" with "em direção ao perigo" under both prompts.
- gpt-5.4-nano missed "portado" (Italian "portare", a false friend of Spanish "portar") in all three Spanish runs, and "vicino" in both Portuguese runs; with v6 it once replaced "vicino" with an invented "porde".
- Asking for the source language in the explanation is followed about half the time; gpt-6-luna follows it more.
- Spanish replies read as Spain Spanish ("pedisteis", "os recomendaron"); B1 judged B1 or B2, a C1 learner (sent C2) judged C1 on gpt-5.4-nano and B2 on gpt-6-luna.

Outcome: v6 caught more on gpt-5.4-nano and the same on gpt-6-luna, so it becomes the app's prompt (D3).

## Change

- `assets/prompts/tutor_response/v6.txt`, the latest template, so the app uses it.
- `scripts/prompt_lab/lab.py`: `expect` per message, a Caught column, a conversation per setup.
- Docs: `prompt-engineering.md` (Mixed-in words), the prompt lab README.

## Tests

- The latest template carries the mixed-in words rule.

## Done when

- `scripts/check.sh` passes.
- On the Pixel, the user's sentence gets "verso" and "perigolos" corrected.
