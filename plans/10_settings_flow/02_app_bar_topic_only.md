---
status: in progress
---

# 02 - Topic picker only in the app bar

## Overview

`00_start.md` D5: the language and CEFR chips leave the conversation app bar; the topic picker takes the title slot on its own.

## Change

- `conversation_screen.dart`: `_LanguageAction` and `_CefrAction` go; the title is the topic picker, still ellipsized.
- `cefr_picker_sheet.dart` and `showLanguagePickerSheet` go, having no caller left.
- `language_picker_sheet.dart` moves to `lib/screens/settings/widgets/language_switch.dart` with what is left (`languageSwitchAction`, `showLanguageSwitchDialog`, `applyLanguageChoice`), and its test to `test/screens/settings/widgets/language_switch_test.dart` without the picker-sheet test.
- `test/screens/conversation/language_copy_test.dart` and `topic_display_test.dart` stop looking for the language chip; the long-topic test still checks the menu and new-conversation buttons stay on screen.

## Done when

- The tests pass and `scripts/check.sh` passes.
- On the Pixel, the app bar shows the menu, the topic and the new-conversation button only. Checked by the user.
