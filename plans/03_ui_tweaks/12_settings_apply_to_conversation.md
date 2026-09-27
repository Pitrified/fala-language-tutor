---
status: done
---

# 12 - Settings apply to the open conversation

## The problem

From the Pixel run of 2026-09-27: changing the language in Settings did not touch the open conversation, only the default for the next one; after a restart, item 11 then found the open conversation in the old language and started a new one. The level behaved the same way. The app bar chips were the only place that changed the open conversation.
Also: saving on the Settings screen said "OpenAI settings saved.", although the screen holds more than OpenAI settings.

## The change

- The language chip's logic moved into `applyLanguageChoice` in `language_picker_sheet.dart`, and both the chip and the Settings language dropdown call it: the default always moves; an empty open conversation switches in place; one with messages asks, and a new conversation starts in the new language only if the user confirms, the old one staying saved.
- The Settings level dropdown also calls `setCefrLevel` on the open conversation, as the level chip does. It applies from the next message and never asks, since a level change does not make the history wrong.
- The help texts under both dropdowns say what now happens. The save message is "Settings saved."
- The temporary storage line in the drawer is gone; its readings on 2026-09-27 are in item 11.

## What the implementation found

- **One behaviour change in the chip:** picking the conversation's own language used to leave the default untouched; now the default moves to it too, as for any other pick.
- **Tests:** three widget tests drive the real Settings screen with a controller whose conversation is empty or started: the level applies in place, the language switches an empty conversation without a dialog, and with messages a dialog appears and confirming starts a French conversation while the Portuguese one keeps its message. All three fail against the previous Settings screen (language still `pt-BR`, no dialog) and pass now.
- **Hive in widget tests:** writes started inside the widget test's fake clock never finish, and the next test's setup waits on them. The taps that write run under `runAsync`, and each test uses its own box names; closing Hive in `tearDown` hung for the same reason.
- **Checked on the Pixel** on 2026-09-27 with build `0.0.1+c45ce050`: a language change asks for a started conversation and switches an empty one in place, and a level change reaches the open conversation.
