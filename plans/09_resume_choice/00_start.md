---
status: in progress
priority: 0
description: |
  On a cold start with a last conversation that has messages, offer "Resume conversation" and
  "New conversation" instead of opening the last conversation directly.
---

# Resume choice

Raised 2026-09-27 during the Pixel run of topic handling. Phases and progress in [`tracking.md`](tracking.md).

## Where this came from

"There should be a resume conversation when we reopen the app with a valid conversation ready. The start one stays." Asked which reading was meant, the answer was an explicit choice with two buttons (user, 2026-09-27).

## How it works today

`ConversationScreen._initConversation` calls `ConversationController.resumeOrStartConversation`: the most recently updated conversation is opened when it is in the default language, with or without messages; otherwise a new one starts. The learner is not asked. The new-conversation button in the app bar is the only way to start fresh.

## Decisions

- D1: the choice is shown only when the conversation that would be resumed has messages. An empty last conversation has nothing to resume, so it is opened as today; a last conversation in another language still leads to a new one, as today.
- D2: only on a cold start, when the screen is built with no conversation open. Coming back from the background keeps the open conversation, as today.
- D3: the choice sits in the conversation body, where the message list would be, with a short summary of the last conversation (topic, message count, date, the last message cut at two lines). The input bar is hidden until a choice is made; the app bar stays, and its new-conversation button also counts as choosing "New conversation".

## Open questions

None.
