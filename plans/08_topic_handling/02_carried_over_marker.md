---
status: done
---

# 02 - A carried-over topic is marked on the new conversation

## Overview

From `00_start.md` Q3 and Q4: a new conversation keeps starting with the last used topic, and says so, since nothing outside the chip shows it today.

## Goal

- The empty conversation shows the topic under "Say something in <language>!" whenever it has one.
- When the topic was carried over, that line reads "Topic: <topic>, from your last conversation".
- Once the learner picks a topic for this conversation, the line reads "Topic: <topic>" without the origin.
- The line goes away with the rest of the empty state once the first message is sent.

## Design

- `ConversationController` gets `topicCarriedOver`: true after `startConversation` with a non-empty topic, since every caller passes the default, which is the last used topic; false after `setTopic`, after `loadConversation` and when `resumeOrStartConversation` resumes a saved conversation. It is not persisted, so an empty conversation resumed after a restart shows "Topic: <topic>" without the origin, which is still true.
- The empty state in `conversation_screen.dart` reads the flag and the conversation's topic; it already rebuilds on `conversationStream`, and `setTopic` emits on it.

## Done when

- Controller tests cover the flag through start, setTopic, resume and load.
- A widget test shows the line with and without the origin, and gone after the first message.
- `scripts/check.sh` passes.
