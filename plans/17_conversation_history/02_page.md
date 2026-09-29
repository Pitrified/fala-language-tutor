---
status: planned
---

# 02 - Conversations page

## Goal

The page itself: the list, the x on each row, Clear all, and a tap that opens a conversation.

## Design

- `lib/screens/history/history_screen.dart`, route `AppRoutes.history = '/conversations'`, top-level in `app.dart` and allowed by the redirect.
- A row per conversation from `history()`: `conversationTitle` as the title; the subtitle has the date of `updatedAt` (`formatMediumDate`), the message count and the language code; an `IconButton` with `Icons.close` and the tooltip "Delete conversation" at the end.
- App bar: a "Clear all" action, disabled when the list is empty, opening an `AlertDialog` ("Delete all conversations?", Cancel, Delete).
- Empty state: "No conversations yet."
- A tap on a row calls `loadConversation(id)` and goes to the conversation screen, stopping speech as the drawer tiles do.
- Drawer: a "Conversations" tile (`Icons.history`) above the Settings header.
- `docs/functional-specs.md`: a Conversations row in the screen inventory and the drawer entry in the Conversation row; `docs/library/conversation-repository.md` if it lists the id format.

## Done when

- Widget tests: rows show the names of conversations with messages and not the empty one; the x removes its row and the conversation from Hive; Clear all with Delete empties the list, with Cancel keeps it; a tap opens the conversation's messages; the drawer tile opens the page. Hive writes run inside `tester.runAsync`.
- `scripts/check.sh` passes; an APK for the Pixel run.
- On the Pixel: the page lists past conversations, deletes one, clears all, and reopens one. Checked by the user.
