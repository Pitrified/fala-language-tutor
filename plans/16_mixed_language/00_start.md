---
status: in progress
priority: 0
description: |
  Corrections catch words from other languages mixed into the learner's message, and the
  Spanish side of the prompt is tried on a Spanish conversation.
---

# Mixed-in words and the Spanish check

## Where this came from

- "yes, run the Spanish test conversation" (user, 2026-09-29): the es-ES samples in `reply_style.json` had not been tried on Spanish learner messages.
- "in the prompt, there should be a note on corrections, to look for other languages used intermixed. For example talking about a kid: "Ele precisa de supervisão claro. Quer descobrir todo mundo e vai caminhar sem dúvida verso o perigolos". That final "verso o perigolos" is blatant Italian with an s attached. Then maybe I got lucky and verso is verso also in Portuguese. So in general it gets picked up by the corrections, but we want to test it a bit." (user, 2026-09-29)

## Decisions

- D1: the prompt lab marks the words a correction should quote in a test message (`expect`) and counts how many were caught, so the check is a number rather than a reading.
- D2: two test conversations in `prompt_lab/`: `mixed_portuguese.json` (about a small child, the user's sentence first, Italian, Spanish and English words mixed in) and `spanish.json` (es-ES, Italian false friends and words, one English word, two grammar errors).
- D3: the rule goes into the app's prompt as `tutor_response/v6.txt` if the lab run shows it does not make things worse.

Phases in [`tracking.md`](tracking.md).
