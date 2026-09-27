# Ui tweaks - implementation tracking

Small UI and functionality fixes, one sub-plan each, from tap-to-reveal translation to the
CEFR picker to how an unparseable reply reads.

This folder ran before `tracking.md` was the convention, so this file was written during the
normalisation pass in
[`../21_plans_query_skill/02_normalisation.md`](https://github.com/Pitrified/flutter-setup-project/blob/main/plans/21_plans_query_skill/02_normalisation.md). The table
is the phase files as they stand; the log is what `plans/00_tracking.md` recorded before it was deleted.

Analysis and decisions in [`00_start.md`](00_start.md).

## Phases

| #  | Phase | Plan | Status |
| -- | -------------------------------------------------------------------------- | ---------------------------------------------------------------------------- | ------ |
| 01 | 01 - Show translation on tap                                               | [`01_show_translation.md`](01_show_translation.md)                           | done |
| 02 | 02 - CEFR level indicator and picker                                       | [`02_cefr_level_picker.md`](02_cefr_level_picker.md)                         | done |
| 03 | 03 - Topic suggestions and picker                                          | [`03_topic_picker.md`](03_topic_picker.md)                                   | done |
| 04 | 04 - Scroll to bottom                                                      | [`04_scroll_to_bottom.md`](04_scroll_to_bottom.md)                           | done |
| 05 | 05 - Higher, wrapping input field                                          | [`05_higher_input_field.md`](05_higher_input_field.md)                       | done |
| 06 | 06 - New conversation button                                               | [`06_new_conversation_button.md`](06_new_conversation_button.md)             | done |
| 07 | 07 - Engine selection: correct model name, OpenAI default, scoped settings | [`07_engine_selection.md`](07_engine_selection.md)                           | done |
| 08 | 08 - A long correction wraps while it streams                               | [`08_long_correction_wrap.md`](08_long_correction_wrap.md)                   | done |
| 09 | 09 - Split CEFR text into guidance + description                           | [`09_cefr_guidance_and_description.md`](09_cefr_guidance_and_description.md) | done |
| 10 | 10 - A malformed reply reads as a failed turn, not as the tutor talking    | [`10_malformed_reply_display.md`](10_malformed_reply_display.md)             | done |
| 11 | 11 - Reopening the app resumes the last conversation                       | [`11_resume_last_conversation.md`](11_resume_last_conversation.md)           | done |
| 12 | 12 - Settings apply to the open conversation                               | [`12_settings_apply_to_conversation.md`](12_settings_apply_to_conversation.md) | done |

Status values: draft / planned / in progress / done / superseded / discarded.

## Log

Append-only. Newest at the bottom.

- 2026-07-15 : items 01 to 03 executed (translation, CEFR picker, topic picker).
- 2026-08-02 : items 04 to 07 and 09 executed (scroll-to-bottom, taller input, new-conversation button, engine selection, CEFR guidance).
- 2026-09-25 : item 10, an unparseable reply now reads as a failed turn rather than as the tutor writing English prose.
- 2026-09-25 : item 08 in the list, long corrections not wrapping while streaming, has no sub-plan; this folder stays in progress until it does.
- 2026-09-26 : item 11 added from the first Pixel run of fala-language-tutor: reopening the app starts a new conversation instead of resuming the last. Planned, with two points to decide before building.
- 2026-09-26 : item 11's two open points decided as proposed (resume only in the current default language; reuse an empty last conversation). Stays `planned`; built later.
- 2026-09-27 : item 08 - a streaming correction whose corrected form had not arrived sat in a `Row` and did not wrap; now rich text like the finished line. Test seen failing first (1450 px overflow).
- 2026-09-27 : item 11 - reopening the app resumes the last conversation when it is in the current default language, and reuses an empty one. Four controller tests, seen failing first. 172 tests.
- 2026-09-27 : item 11 confirmed on the Pixel with build `0.0.1+470faa9c` and a temporary storage line in the drawer; the failure on the previous build was most likely a bad reinstall. `listAll` now skips unreadable entries. The drawer shows the version, `0.0.1+<commit>`, set by `scripts/build-apk.sh`.
- 2026-09-27 : item 12 - the Settings language and level dropdowns apply to the open conversation, through the same helper as the language chip; three widget tests, failing against the old screen. Save message made general. Diagnostic line removed.
