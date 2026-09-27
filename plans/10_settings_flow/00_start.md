---
status: in progress
priority: 0
description: |
  Split Settings into a Language page and a Model page, reached from two drawer entries under a thin
  "Settings" header, and drop the language and CEFR chips from the conversation app bar.
---

# Settings flow

Raised 2026-09-27 after the resume choice was merged. Phases and progress in [`tracking.md`](tracking.md).

## Where this came from

"The left drawer when opened should show a thin header settings, below that two entries, their esthetics like the current existing one. One entry for language, which holds the existing settings entries for language and cefr. One for model, which leads to a page holding the rest of the current settings, with provider picker and then provider details. From the general chat interface, we remove the language and cefr buttons, only leave the topic picker." (user, 2026-09-27)

## How it works today

- The drawer has a tall `DrawerHeader` reading "fala", one "Settings" tile and a disabled version line.
- `/settings` is one page: engine dropdown, language dropdown, "Default CEFR level" dropdown, and the OpenAI section when OpenAI is the engine.
- The Settings dropdowns already change the open conversation the way the app bar chips do: language through `applyLanguageChoice` (in place while empty, a confirmed new conversation once it has messages), CEFR from the next message. Removing the chips therefore removes a second route to the same behaviour, not a capability.
- The welcome screen has a gear pushing `/settings`.

## Decisions

- D1: the drawer shows a thin "Settings" label instead of the "fala" `DrawerHeader`, then a "Language" and a "Model" `ListTile` in the style of the current Settings tile, then the version line.
- D2: `/settings` stays, as a thin page listing the same two entries, so the welcome screen's gear keeps a target (user, 2026-09-27). The drawer and that page share one widget.
- D3: `/settings/language` holds the language and CEFR dropdowns with their help text; the CEFR header reads "CEFR level", since it changes the open conversation and not only the default. `/settings/model` holds the engine dropdown and, below it, the details of the selected engine (the OpenAI section; Fake has none).
- D4: no current values in the drawer entries. They are shown on the pages, and the learner is not expected to change them often (user, 2026-09-27).
- D5: the conversation app bar keeps the menu button, the topic picker and the new-conversation button. The language and CEFR chips go, and with them the code only they used: `cefr_picker_sheet.dart` and `showLanguagePickerSheet`. The language-switch rule, its confirm dialog and `applyLanguageChoice` move next to their only caller, under `screens/settings/`.

## Open questions

None.
