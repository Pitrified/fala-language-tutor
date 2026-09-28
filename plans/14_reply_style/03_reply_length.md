---
status: in progress
---

# 03 - Reply length setting

## Overview

The verbosity setting from the draft: short, normal or long replies, sent as the prompt's length rule. Prompt lab run 4 in `00_start.md` chose the length rule over the API `verbosity` parameter. `00_start.md` Q1 (a setting of its own, or tied to the level) is settled by the lab: length and level were set independently there and both held.

## Change

- `ReplyLength` (short, normal, long), with a label and a description.
- `AppSettingsRepository`: `reply_length`, normal when unset. One setting for every conversation.
- `replyLengthProvider`; `ConversationController.replyLength`, read on every message.
- Language page: a "Reply length" section under the CEFR level, the description of the chosen length under the dropdown.
- Docs: `functional-specs.md` (screens, stored settings), `prompt-engineering.md` (length rule).

## Tests

- The setting defaults to normal and round-trips.
- The controller sends the short and then the long rule as the setting changes between messages.
- The dropdown saves the choice and shows its description.

## Done when

- The tests pass and `scripts/check.sh` passes.
- On the Pixel, short and long replies differ in length as described.
