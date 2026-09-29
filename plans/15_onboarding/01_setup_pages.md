---
status: done
---

# 01 - Setup pages

## Change

- `onboarding_done` setting; `onboardingDoneProvider`, `onboardingNeededProvider` (D1).
- `ModelSettingsBody`, `LanguageLevelSettings` and `ReplySettings` split out of the Model and Language pages, which now compose them (D2).
- `OnboardingScreen` for the three steps at `/onboarding/model`, `/onboarding/language`, `/onboarding/reply`, with "n of 3", Next or Start, and "Set it later" on the model step (D3; removed again in phase 03).
- Welcome: "Get started" into the first step on a new install.
- Docs: `functional-specs.md` (screens, stored settings).

## Tests

- Without a key: Next is off on the model step; "Set it later", Next, Start go through the three pages with the right settings on each, record the setup as done and land on welcome.
- With a key: Next is on, and Start opens the conversation.
- A new install needs the setup; after `finish` it does not.

## Done when

- The tests pass and `scripts/check.sh` passes.
- On the Pixel, after clearing the app's data: Get started, the three pages in order, and the conversation after Start with a key saved on the first page.
