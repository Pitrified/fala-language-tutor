---
status: draft
priority: 0
description: |
  Clarify how topics work: what is stored where, whether custom topics are remembered as a
  list, whether suggestions follow the target language, and where a topic can be set. Today a
  custom topic is kept only as the current one and the suggestion list is fixed.
---

# Topic handling

Draft spin-off, raised 2026-09-27. No phases derived.

## Where this came from

The question "are custom topics persisted?", after the UI fixes closed. The answer was "partly", and the ask was to clarify topic handling in a folder of its own.

## How it works today

Read from the code on 2026-09-27, not run on a device.

- **A topic is a plain string.** `Topic` (`lib/models/topic.dart`) carries a value and an `isCustom` flag; the flag is picker metadata and is not stored.
- **Stored in two places.** On the conversation (`Conversation.topic`, in the conversations box), so a resumed conversation keeps its topic; and as the default for new conversations (`default_topic` in `AppSettingsRepository`).
- **Set only from the topic chip** in the conversation's app bar. Picking a topic there, suggested or typed, sets the open conversation's topic and the default together. The Settings screen has no topic control, unlike language and level since `03_ui_tweaks` item 12.
- **The picker** (`topic_picker_sheet.dart`) has a text field for a custom topic, pre-filled when the current topic is custom, and a fixed list, `kSuggestedTopics`: fifteen English labels.
- **No history.** Applying another topic replaces the stored one; a custom topic typed earlier is gone once another is picked.
- **The prompt** receives the string as `{{topic}}` and is told to steer toward it without forcing it, or to follow the learner when it is empty (`assets/prompts/tutor_response/v3.txt`).

## What looks wrong or unclear

- **"Brazilian culture" is a suggestion for every target language.** The list predates the language setting (`03_ui_tweaks` and the source repo's target-language work), so a Spanish or French learner is offered Brazil.
- **Custom topics are not remembered.** A learner who types the same few topics has to retype them.
- **The default topic is sticky and invisible.** Picking a topic for one conversation makes it the topic of every new one, and nothing outside the chip shows or clears it.
- **Topic and language are independent.** A custom topic typed in Portuguese (for example "ciclismo") stays the default after switching to French.

## Open questions

- Q1: remember custom topics as a list?
  a. a short list of recent custom topics in the picker, above the suggestions, newest first.
  b. keep only the current one, as today.
  Recommended: a, with a small cap such as five, and a way to remove one. It is the question that raised this folder.
  NEW_ANS:
- Q2: should suggestions follow the target language?
  a. a neutral list for every language, dropping "Brazilian culture" or making it "Culture of <country>" from the language's region.
  b. a per-language list.
  Recommended: a. The labels are English like the rest of the UI; only the one culture entry depends on the language, and it can be built from `TargetLanguage`.
  NEW_ANS:
- Q3: should picking a topic for a conversation also change the default for new ones?
  a. yes, as today.
  b. no: the chip sets the conversation's topic only, and the default lives in Settings.
  c. new conversations start with no topic, and the recent list makes picking one cheap.
  Recommended: c if Q1 is a; otherwise a. A sticky default nobody sees is how a learner ends up talking about cycling in every conversation.
  NEW_ANS:
- Q4: a topic control in Settings, like language and level?
  Recommended: only if Q3 is b; with a or c the chip is enough.
  NEW_ANS:
- Q5: are recent custom topics kept per target language?
  Recommended: yes, if Q1 is a: a topic typed in one language is written in that language.
  NEW_ANS:
