---
status: done
priority: 0
description: |
  Point a user without an API key at the Model page: "Setup model" on the welcome screen, a red
  "Model setup needed" strip in the conversation, and a "Source: fala" link in the drawer.
---

# Model setup prompt

Raised 2026-09-27 after the settings flow was merged. Phases and progress in [`tracking.md`](tracking.md).

## Where this came from

"When a model which requires a key does not have the key set (which is the standard when a user downloads the app), the start learning button should be replaced with a "Setup model", which leads to the model settings page. Then if a user unsets the key, in the main chat page should appear a red ❗ below the top bar with a text saying "model setup needed", which also leads to the model settings page. As people might wonder where their key goes, add a link to the repo GitHub over the version number. Thin gray, "Source: fala", fala underlined, link to the repo there" (user, 2026-09-27)

## How it works today

- OpenAI is the default engine and a fresh install has no key. The engine initializes without one, so the welcome screen offers "Start learning", and the first message fails with a message pointing at Settings.
- Nothing outside the Model page reads whether a key is stored.
- The drawer ends with a disabled "Version ..." line. fala has no dependency that can open a URL.

## Decisions

- D1: "needs setup" means the selected engine requires a key (`EngineKind.requiresKey`, true for OpenAI) and `ApiKeyStore` holds none. It is `modelSetupNeededProvider`, `null` until the key store answers, so neither screen shows the wrong prompt for a frame. The Model page invalidates the key's provider after saving or clearing.
- D2: on the welcome screen, once ready, the button reads "Setup model" and pushes the Model page while setup is needed; coming back after saving a key shows "Start learning".
- D3: in the conversation, a strip under the app bar in the error container colour, with a red exclamation icon, "Model setup needed" and a chevron. The whole strip opens the Model page.
- D4: "Source: fala" above the version line, in the version line's grey, "fala" underlined, opening https://github.com/Pitrified/fala-language-tutor in the browser. The repository is public (user, 2026-09-27).
- D5: `url_launcher` is added for D4, approved by the user on 2026-09-27. It is the Flutter team's plugin; the alternative was a hand-written Android intent channel for one link. The manifest declares an https VIEW query, which Android 11 and later need to resolve the browser.

## Open questions

None.
