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
- A "say it better" mode: besides the correction, the tutor suggests another way to express what the learner said, with slightly richer words or structures in line with the selected level, so a correct but plain sentence still gets something to learn from. "on top of the correction there could be a mode where the engine also suggests a similar way to express whatever the user said, using slightly more complex words, in line with the selected level" (user, 2026-09-28). It would be a new field in `TutorResponse`, empty when there is nothing to add, and a toggle.
- Measure before changing: the same conversation at A1 and at C1, with sentence length and word counts compared, to see how much the level changes today.

## Open questions

- Q1: Is verbosity a separate setting, or tied to the level?
  ANS: ...
- Q2: Does the "say it better" suggestion show for every message, or only when the learner's message had no errors?
  ANS: a setting decides. On, it comes with every reply automatically. Off, a button beside the reply bubble asks for it on demand: "The user has a setting to toggle, to turn it on every time automatically, or when not set, show it by pressing a button on the side of the response message bubble." (user, 2026-09-28). Consequence to design for: on demand means a second request to the model after the reply, with the learner's message and the level, while the automatic mode can ride in the same structured response.
