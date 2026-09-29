---
status: planned
---

# 01 - Ids, names and deletion in the controller

## Goal

The data side of the page, testable without a widget: UUID ids for new conversations, the derived name, the list, and deletion that never leaves the open conversation dangling.

## Design

- `lib/services/conversation/conversation_id.dart`: `newConversationId()`, a v4 UUID (`xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx`, lowercase hex) from 16 bytes of `Random.secure()` with the version and variant bits set. `startConversation` uses it.
- `lib/models/conversation_title.dart`: `conversationTitle(Conversation)`, the topic cut at 30 characters with `...` appended when cut, or "No topic". The date is formatted in the widget, since it needs `MaterialLocalizations`.
- `ConversationController`:
  - `List<Conversation> history()`: `repository.listAll()` without the conversations that have no messages.
  - `Future<void> deleteConversation(String id, {required ...defaults})`: deletes it; when it is the open one, starts a new one with the defaults passed in.
  - `Future<void> deleteAllConversations({required ...defaults})`: clears the box, then starts a new one when a conversation was open.
  - Each notifies a `historyStream` (or the page re-reads after the call); the choice is made in the code, whichever is shorter.
- The defaults come from the caller (the page reads the language, level and topic providers), as `_newConversation` does today, so the controller keeps no settings of its own.

## Done when

- Tests: the id matches the v4 pattern and two calls differ; the title cuts at 30, keeps a short topic whole, and gives "No topic" for an empty one; `history` skips empty conversations and is newest first; deleting another conversation keeps the open one; deleting the open one opens a new empty one; delete all leaves only that new one. The deletion tests are mutation-checked.
- `scripts/check.sh` passes.
