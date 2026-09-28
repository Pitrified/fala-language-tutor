# Reply length and complexity - implementation tracking

Make the tutor's replies fit the learner: a model chosen on evidence, a verbosity setting, and a CEFR level that changes how complex the reply is.

Analysis, prompt lab runs and decisions in [`00_start.md`](00_start.md).

## Phases

| #  | Phase | Plan | Status |
| -- | ----- | ---- | ------ |
| 01 | Model picker with the compared models | [`01_model_picker.md`](01_model_picker.md) | in progress |

Status values: draft / planned / in progress / done / superseded / discarded.

## Log

Append-only. Newest at the bottom.

- 2026-09-28 : draft written from user notes on verbosity, level and "say it better".
- 2026-09-28 : prompt lab runs 1 to 4 (v3 to v7, gpt-6-luna, gpt-4o-mini, gpt-5.4-nano, reasoning effort, API verbosity); results in `00_start.md`. The script became `scripts/prompt_lab/`.
- 2026-09-28 : default model gpt-5.4-nano, the compared models in a dropdown (user). Phase 01 derived and built.
