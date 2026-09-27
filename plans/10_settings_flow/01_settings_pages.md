---
status: done
---

# 01 - Language and Model pages, drawer entries

## Overview

`00_start.md` D1 to D4: the single Settings page becomes a thin index of two entries, each opening its own page, and the drawer lists the same entries under a thin "Settings" label.

## Change

- `lib/screens/settings/settings_entries.dart`: `SettingsEntries`, the two `ListTile`s ("Language", "Model"), used by the drawer and by `/settings`. A tap pops the drawer when there is one, then pushes the page.
- `settings_screen.dart`: `/settings` shows `SettingsEntries` only.
- `language_settings_screen.dart`: the language and CEFR dropdowns with their help text, the CEFR header renamed "CEFR level".
- `model_settings_screen.dart`: the engine dropdown and the OpenAI section.
- `app.dart`: `/settings/language` and `/settings/model` as child routes of `/settings`.
- The drawer in `conversation_screen.dart`: a thin "Settings" label, `SettingsEntries`, the version line.

## Tests

- The existing settings-applies-to-conversation tests run against the Language page.
- New: the drawer shows "Settings", "Language" and "Model", and tapping each opens its page; `/settings` lists the same two entries.

## Done when

- The tests pass and `scripts/check.sh` passes.
- On the Pixel, the drawer and both pages look right. Checked by the user on 2026-09-27.
