---
status: done
---

# 01 - Recent custom topics in the picker

## Overview

From `00_start.md` Q1 and Q5: the picker remembers the last five custom topics, one list for every target language.

## Goal

- A custom topic that is applied, typed or picked from the recent list, goes to the top of a list of recent topics. The list holds five; a sixth drops the oldest. A topic already in the list moves to the top rather than appearing twice.
- Suggested topics (`kSuggestedTopics`) and the empty topic never enter the list.
- The picker shows the list under a "Recent" label, between the custom field and the suggestions, newest first, only when it is not empty.
- Each recent entry has a remove button that drops it from the list without closing the picker.
- The list is stored in `AppSettingsRepository` and survives a restart. One list for all languages.

## Design

- `lib/models/topic.dart`: a pure `pushRecentTopic(List<String> recent, String topic)` returning the new list, with the cap as `kRecentTopicsCap = 5`. Pure so the rule is unit tested without Hive.
- `AppSettingsRepository`: key `recent_topics`, stored as a JSON array of strings in the existing `Box<String>`. A value that does not parse as a list of strings reads as empty.
- `settings_provider.dart`: `RecentTopicsNotifier` with `remember(String)` and `remove(String)`, writing through to the repository like the other settings notifiers.
- `topic_picker_sheet.dart`: takes `recent` and an `onRemoveRecent` callback, and keeps a local copy of the list so a removal shows at once. The sheet stays presentational; the chip in `conversation_screen.dart` calls the notifier.

## Done when

- Unit tests cover the push rule (order, dedupe, cap, suggested and empty ignored) and the repository round-trip and bad-value fallback.
- A widget test shows the recent section, picks from it, and removes an entry.
- `scripts/check.sh` passes.
