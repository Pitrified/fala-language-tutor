---
status: in progress
---

# 03 - A long topic keeps the app bar on screen

## Overview

From the Pixel run of phases 01 and 02 (user, 2026-09-27): a long topic made the app bar too wide and pushed the menu button, the way to Settings, off screen.

## Cause

The language, topic and CEFR chips and the new-conversation button were all `AppBar.actions`, which are laid out at their own width and never shrink. The topic label was cut at 18 characters, which does not bound its width: on the Pixel the four items still did not fit next to the menu button and the title. A widget test at 412 logical pixels, the Pixel's portrait width, reproduced it as a 191 pixel overflow of the actions row with the test font.

## Change

- The three chips move into the app bar's title slot as a row; the topic chip is `Flexible` and its label is one line with an ellipsis, so it takes whatever width is left. The new-conversation button stays in `actions`.
- The 18-character cut is gone; the width decides where the label ends.
- The "fala" title text is dropped from the app bar. The drawer header already shows it.
- In the picker, a topic's label is cut at two lines with an ellipsis, so a long recent topic does not make one entry fill the list (`00_start.md` Q6).

## Done when

- The widget test with a long topic at 412 pixels finds the menu button, the chips and the new-conversation button inside the screen and not overlapping, with no overflow.
- A widget test finds a long recent topic cut at two lines.
- `scripts/check.sh` passes.
- On the Pixel, the menu button stays visible with a long topic. Not yet checked.
