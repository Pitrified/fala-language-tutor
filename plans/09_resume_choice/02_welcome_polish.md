---
status: in progress
---

# 02 - Welcome screen wording

## Overview

From the Pixel run of phase 01 (user, 2026-09-27): the first screen's button reads "Start learning" instead of "Start Conversation", and the "Model: <name>" line under the tagline goes. The engine and model are still shown and set in Settings.

## Change

- `welcome_screen.dart`: the button label, and the ready state shows nothing where the model line was. `_modelLabel` and its `engine_kind.dart` import go with it. "Loading..." stays for the loading state.
- `test/screens/welcome/welcome_screen_test.dart`, the first test of this screen: in the ready state it finds "Start learning" and no "Model:" text. It failed on the old screen before the change.

## Done when

- The widget test passes and `scripts/check.sh` passes.
- On the Pixel, the first screen shows "Start learning" with no model line. Not yet checked.
