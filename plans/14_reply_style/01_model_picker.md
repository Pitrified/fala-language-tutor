---
status: done
---

# 01 - Model picker with the compared models

## Overview

"gpt-5.4-nano is default, add the two tested model in a dropdown when picking the model with the brief explanation of the differences" (user, 2026-09-28), after prompt lab run 4 in `00_start.md`.

## Change

- `openai_models.dart`: the offered models (gpt-5.4-nano, gpt-6-luna), each with a one-line description and the reasoning effort to send (`none`).
- `OpenAiInferenceEngine`: sends `reasoning_effort` for an offered model, nothing for any other id.
- `AppSettingsRepository.defaultOpenaiModel`: the first offered model, gpt-5.4-nano. A phone that never saved a model id switches to it; one that did keeps its id.
- Model page: the free-text model field becomes a dropdown, saved on selection, with the chosen model's description as helper text. A stored id not in the list stays listed.
- Docs: `functional-specs.md` (model row), `prompt-engineering.md` (Models).

The prompt stays v3; v7 and the verbosity setting are later phases.

## Tests

- The default is gpt-5.4-nano.
- The request body has `reasoning_effort: none` for gpt-5.4-nano and no `reasoning_effort` for gpt-4o-mini.
- The Model page shows the default and its description; choosing gpt-6-luna saves it and shows its description; a stored gpt-4o-mini stays listed.

## Done when

- The tests pass and `scripts/check.sh` passes.
- On the Pixel, a conversation replies on gpt-5.4-nano, and switching to gpt-6-luna replies too.
