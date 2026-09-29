---
status: in progress
priority: 0
description: |
  A Conversations page listing the saved conversations by name and date, with an x on each
  row to delete it and a Clear all button.
---

# Conversation history

Phases and progress in [`tracking.md`](tracking.md).

## Where this came from

"work on a conversation history, new folder, should be quite straight forward. Conversation name pretty for now it's just topic[:cut] and date. Conversation UUID for technical joins if we need them. Messages. Topic. Date. A page to see the list, a clear all button, x buttons to delete one by one." (user, 2026-09-29)

## What exists

- `Conversation` already holds `id`, `createdAt`, `updatedAt`, `messages`, `topic`, `language` and `cefrLevel`, one JSON string per conversation in the `conversations` Hive box, keyed by `id`.
- `ConversationRepository` has `listAll` (newest `updatedAt` first, unreadable entries skipped and counted), `delete(id)` and `deleteAll()`. Nothing in the UI calls the last two.
- `id` is `DateTime.now().millisecondsSinceEpoch.toString()`. Unique on one device, but not a UUID.
- Every "New conversation" saves an empty conversation, and the app opens the last one on a cold start (`resumeOrStartConversation`, and the resume choice when it has messages). Nothing lists the others: they pile up in Hive unseen.
- `uuid` 4.5.3 is in `pubspec.lock` as a transitive dependency only. Importing it needs a direct dependency, which needs approval.

## Decisions

- D1: the name is derived, not stored: the topic cut at 30 characters with an ellipsis, or "No topic", then the date of `createdAt` in the device's medium format (as the resume choice shows it). A stored name would go stale when the topic changes. Provisional: "for now" per the request.
- D2: new conversations get a random v4 UUID as `id`, from a short in-house generator on `Random.secure()` rather than the `uuid` package. Existing conversations keep their timestamp ids; `id` stays an opaque string, so both kinds live side by side and nothing is migrated.
- D3: the page lists only conversations with messages. The empty ones that "New conversation" leaves behind are not history; Clear all deletes them too.
- D4: each row shows the name, the date, the message count and the language code, with an x at the end. The x deletes without a dialog. Clear all, in the app bar, asks for confirmation first, since it cannot be undone.
- D5: tapping a row opens that conversation in the conversation screen, as "Resume conversation" does. Provisional: the request lists the page's contents, not what a tap does, and opening is the one use of a list of past conversations that needs nothing new.
- D6: the page is a top-level route `/conversations`, reached from a "Conversations" tile at the top of the drawer, above Settings. It is not a setting.
- D7: deleting the open conversation, one by one or with Clear all, starts a new empty one in the default language, level and topic, so the conversation screen never shows a conversation that is no longer stored.

## Open questions

None.
