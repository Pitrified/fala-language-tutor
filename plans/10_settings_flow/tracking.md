# Settings flow - implementation tracking

Split Settings into Language and Model pages reached from the drawer, and keep only the topic picker in the conversation app bar.

Analysis and decisions in [`00_start.md`](00_start.md).

## Phases

| #  | Phase | Plan | Status |
| -- | ----- | ---- | ------ |
| 01 | Language and Model pages, drawer entries | [`01_settings_pages.md`](01_settings_pages.md) | in progress |
| 02 | Topic picker only in the app bar | [`02_app_bar_topic_only.md`](02_app_bar_topic_only.md) | in progress |

Status values: draft / planned / in progress / done / superseded / discarded.

## Log

Append-only. Newest at the bottom.

- 2026-09-27 : folder raised from the user's request; D1 to D5 settled in the same exchange, phases 01 and 02 derived.
- 2026-09-27 : phases 01 and 02 built. `SettingsEntries` shared by the drawer and `/settings`; `/settings/language` and `/settings/model` as child routes; the app bar title is the topic picker alone; `cefr_picker_sheet.dart` and `showLanguagePickerSheet` removed, the rest of the language picker file moved to `screens/settings/widgets/language_switch.dart`. `settings_entries_test.dart` new, and seen failing with the drawer close removed. `scripts/check.sh` passes; both phases stay in progress until the Pixel run.
