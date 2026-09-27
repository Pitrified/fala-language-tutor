---
status: done
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

## Decided

Both proposals below accepted by the user on 2026-09-26, and built on 2026-09-27.


- **The default language changed since that conversation.** A conversation's language is fixed once it has messages (`docs/functional-specs.md`, "Target language"). Resuming a Portuguese conversation after the default became Spanish either continues in Portuguese, or starts a new Spanish one and leaves the Portuguese one saved.
  Decided: resume only when the last conversation's language matches the current default; otherwise start a new one. That matches what the user did on the Pixel, and the old conversation stays on disk.
- **The last conversation has no messages.** Decided: reuse it rather than creating another empty one, so reopening the app repeatedly does not pile up empty conversations.

## Done when

- A controller test: with a saved conversation, entering resumes it; with none, a new one starts; with a saved conversation in another language, a new one starts.
- `scripts/check.sh` passes, and the Pixel shows the last conversation after a restart.

## What the implementation found

- `ConversationController.resumeOrStartConversation` takes the first of `ConversationRepository.listAll()`, which is already newest first, and resumes it when its language matches; otherwise it calls `startConversation`. The conversation screen calls it where it used to call `startConversation` on entry. The "new conversation" button still calls `startConversation`.
- **Tests seen failing first**, as a compile error while the method did not exist, then passing: resume in the same language after a simulated restart (a second controller over the same repository), a new conversation when none is saved, a new one when the default language changed (the old one still saved with its messages), and reuse of an empty last conversation.
- **An empty conversation in another language** is left saved when a new one starts. Reopening the app repeatedly in one language does not pile them up; switching language each time would leave one empty conversation per switch. Not handled, since nothing lists conversations to the user yet.
- Not checked on a device yet, nor through `scripts/e2e.sh`, which needs an emulator.
