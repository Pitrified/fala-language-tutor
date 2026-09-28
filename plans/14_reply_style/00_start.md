---
status: draft
priority: 0
description: |
  Make the tutor's replies fit the learner: a verbosity setting, and a CEFR level that
  actually changes how complex the reply is.
---

# Reply length and complexity

Status: note. Nothing researched or implemented.

## Where this came from

"We might want a setting for the verbosity / Cefr does not change much the actual complexity of the response" (user, 2026-09-28).

## What the code gives us today

- The prompt in use is `assets/prompts/tutor_response/v3.txt`. The level enters it twice: "The user is learning {{target_language}} at {{cefr_level}} level" and the rule "Match complexity to {{cefr_level}} level." Nothing describes what a level means, and nothing sets the length of the reply beyond "Keep your reply conversational and encouraging."
- The level is a setting on the Language page and applies to the open conversation.

## Ideas to weigh later

- A verbosity setting (short / normal / long), passed to the prompt as a length rule, such as a sentence count.
- Concrete per-level instructions in the prompt in place of the bare level name: sentence length, tenses allowed, vocabulary range, idioms or none.
- Measure before changing: the same conversation at A1 and at C1, with sentence length and word counts compared, to see how much the level changes today.

## Open questions

- Q1: Is verbosity a separate setting, or tied to the level?
  ANS: ...
