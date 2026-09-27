---
status: done
---

# 01 - Resume or new on a cold start

## Goal

- On a cold start, when the last conversation is in the default language and has messages, the body shows a summary of it and two buttons, "Resume conversation" and "New conversation". Nothing is opened until one is tapped.
- "Resume conversation" opens that conversation with its messages. "New conversation" starts one with the defaults, as the app bar button does; the old one stays saved.
- Otherwise the start is unchanged: an empty last conversation is opened, and a last conversation in another language leads to a new one.

## Design

- `ConversationController.resumableConversation(language)`: the conversation `resumeOrStartConversation` would open, when it has messages; `null` otherwise. Read-only, so the screen can decide before anything is opened.
- `ConversationScreen`: `_initConversation` keeps it in state when there is one and shows the choice; otherwise calls `resumeOrStartConversation` as today. Resume calls `loadConversation`. New calls the existing `_newConversation`, which also clears the choice when reached from the app bar.
- `widgets/resume_choice.dart`: the summary and the two buttons, presentational, with callbacks.

## Done when

- Controller tests cover `resumableConversation`: messages, empty, other language, none saved.
- Widget tests: the choice shows for a last conversation with messages; Resume shows its messages; New shows the empty state and keeps the old conversation saved; an empty last conversation opens with no choice.
- `scripts/check.sh` passes.
- On the Pixel, a cold start offers the choice. Checked by the user on 2026-09-27.
