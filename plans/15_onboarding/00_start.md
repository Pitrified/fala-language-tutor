---
status: in progress
priority: 0
description: |
  First-run setup pages after the model setup: language and level, then reply length,
  "say it better" and speech.
---

# First-run setup

## Where this came from

"When onboarding a new user, show two pages in order, one for the language and level setup, the next for the other three settings of length, auto say it better and speech. This after the model setup, which is mandatory, but skippable with a "set it later". The other two language setting pages can just accept default, the next button is already enabled." (user, 2026-09-29)

## What the code gives us today

- The welcome screen shows "Setup model", opening the Model page, while the selected engine needs a key and none is stored, else "Start learning". There is no first-run flow and no "set it later".
- The Language page holds language, level, reply length, "say it better" and speech, as private widgets of one screen.

## Decisions

- D1: a new install is one with the setup not done and the model needing setup (no key stored). Current users, who all have a key, never see the pages. Not asked: it follows from "a new user".
- D2: the pages reuse the settings widgets, split out of the Language and Model pages, so the settings save as they change and the settings pages stay the same.
- D3: the model page's Next waits for the model to be ready; "Set it later" goes on without it. The last page's Start records the setup as done, then opens the conversation, or the welcome screen (which offers "Setup model") while the model still needs setup.
- D4: the setup is done only after Start. Leaving halfway shows it again on the next launch, unless a key was saved on the way.

Phases in [`tracking.md`](tracking.md).
