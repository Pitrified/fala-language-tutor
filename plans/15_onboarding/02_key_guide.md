---
status: in progress
---

# 02 - Guide to getting an OpenAI key

## Overview

"there should also be a link in the "setup api Key" Pages, and near the settings entry, linking to a guide here on GitHub on how to setup an openai key" (user, 2026-09-29).

## Change

- `docs/openai-key.md`: account, prepaid credit, creating the key, entering it in fala, what the key allows and how to see the spending. The OpenAI links are the ones OpenAI's own quickstart uses (`platform.openai.com/api-keys`, `platform.openai.com/account/billing/overview`); the dashboard pages themselves refuse requests from this box, so their current layout was not read.
- `openAiKeyGuideUrl` in `build_info.dart`, next to the Sherpa guide's.
- "How to get an OpenAI key": a button under the key field on the Model page, which is also the first setup page, and a tile under Model in the settings list (drawer and Settings index).
- Docs: `functional-specs.md` (Settings and Model rows).

## Tests

- The Model page and the Settings index show the link.
- The link's path is a file in this repository.

## Done when

- The tests pass and `scripts/check.sh` passes.
- On the Pixel, both links open the guide (it 404s until the branch is merged, as the Sherpa guide did).
