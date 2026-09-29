---
status: in progress
---

# 03 - Setup tweaks after the first look

## Change

- "Set it later" removed from the model page (`00_start.md` D3, revised).
- Diagnostics: "Run first-run setup again" in the app bar, opening the first setup page (D5).
- Language page and setup: the language's own name under the dropdown removed (D6).
- The key guide tile in the settings list removed; the link under the key field stays: "remove the \"How to get an OpenAI key\" dedicated entry in the drawer. The link from the key setup section in the model settings page is ok" (user, 2026-09-29).
- Docs: `functional-specs.md` (First-run setup and Settings rows).

## Tests

- Without a key the model page's Next is off and there is no "Set it later".
- With a key: Next through the three pages, each with its settings; Start records the setup and opens the conversation.
- The Diagnostics button opens the first setup page.
- The settings list has no key guide entry.

## Done when

- The tests pass and `scripts/check.sh` passes.
- On the Pixel, from Diagnostics: the three pages, no "Set it later", no second language name, and the conversation after Start.
