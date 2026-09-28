# Reply length and complexity - implementation tracking

Make the tutor's replies fit the learner: a model chosen on evidence, a verbosity setting, and a CEFR level that changes how complex the reply is.

Analysis, prompt lab runs and decisions in [`00_start.md`](00_start.md).

## Phases

| #  | Phase | Plan | Status |
| -- | ----- | ---- | ------ |
| 01 | Model picker with the compared models | [`01_model_picker.md`](01_model_picker.md) | done |
| 02 | Level-shaped prompt in the app | [`02_prompt_v4.md`](02_prompt_v4.md) | in progress |
| 03 | Reply length setting | [`03_reply_length.md`](03_reply_length.md) | in progress |

Status values: draft / planned / in progress / done / superseded / discarded.

## Log

Append-only. Newest at the bottom.

- 2026-09-28 : draft written from user notes on verbosity, level and "say it better".
- 2026-09-28 : prompt lab runs 1 to 4 (v3 to v7, gpt-6-luna, gpt-4o-mini, gpt-5.4-nano, reasoning effort, API verbosity); results in `00_start.md`. The script became `scripts/prompt_lab/`.
- 2026-09-28 : default model gpt-5.4-nano, the compared models in a dropdown (user). Phase 01 derived and built.
- 2026-09-28 : Pixel run of 0.0.1+fe650ca1 (user): the Model page shows gpt-5.4-nano with its description, a conversation replies, and it replies after switching to gpt-6-luna. Phase 01 done. Phases 02 (v7 prompt in the app) and 03 (verbosity setting) asked for: "both phases".
- 2026-09-28 : phase 02 built. `tutor_response/v4.txt` (lab v7 with `{{reply_level}}` and `{{reply_samples}}`), `reply_style.json` (reply level per learner level with C1 to C2, level guides rewritten without Portuguese grammar names, pt-BR and es-ES samples, length rules), developer and user messages, the no-op filter. The prompt lab reads `reply_style.json` directly. Lab check of the app's v4 on the Lisbon conversation: B1 judged B1 on gpt-5.4-nano and gpt-6-luna (32 and 30 words per reply); a C1 learner (sent C2) judged C1 on both (60 and 59 words, 19 words per sentence); one no-op on gpt-5.4-nano, which the filter drops. A mutation (filter call removed) was seen failing the controller test. Stays in progress until the Pixel run.
- 2026-09-28 : phase 03 built: `ReplyLength`, the `reply_length` setting, the Reply length section on the Language page, the controller sending the matching length rule. A mutation (rule fixed at normal) was seen failing the controller test. Stays in progress until the Pixel run.
