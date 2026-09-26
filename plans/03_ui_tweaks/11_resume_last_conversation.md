---
status: planned
---

# 11 - Reopening the app resumes the last conversation

## The problem

Found on the Pixel on 2026-09-26: after closing and reopening the app, the settings are kept but the conversation is gone.
It is not lost. Every conversation is saved in Hive, but `ConversationScreen._initConversation` starts a new one whenever the controller has none, and at startup it never has one, because nothing loads the most recent conversation.
The spec's demo-ready list has "Conversation persists across app restarts", unchecked.

## The change

- On entering the conversation screen with no current conversation, load the most recently updated one from `ConversationRepository.list()` (already sorted by `updatedAt`, newest first) and continue it; start a new one only when there is none.
- The "new conversation" button (item 06) keeps starting a fresh one, and the previous stays saved.
- The logic goes in `ConversationController`, as a method the screen calls, not in the widget: no business logic in widgets.

## Decide before building

- **The default language changed since that conversation.** A conversation's language is fixed once it has messages (`docs/functional-specs.md`, "Target language"). Resuming a Portuguese conversation after the default became Spanish either continues in Portuguese, or starts a new Spanish one and leaves the Portuguese one saved.
  Proposed: resume only when the last conversation's language matches the current default; otherwise start a new one. That matches what the user did on the Pixel, and the old conversation stays on disk.
- **The last conversation has no messages.** Proposed: reuse it rather than creating another empty one, so reopening the app repeatedly does not pile up empty conversations.

## Done when

- A controller test: with a saved conversation, entering resumes it; with none, a new one starts; with a saved conversation in another language, a new one starts.
- `scripts/check.sh` passes, and the Pixel shows the last conversation after a restart.
