---
status: done
---

# 02 - Read replies aloud automatically

## Overview

`00_start.md` D4 and the settings half of D6.

## Change

- `AppSettingsRepository`: `read_replies_aloud`, `'true'` or `'false'`, off when unset. `readRepliesAloudProvider`.
- Language page: a "Speech" section with the switch, and a line with "Install voice" when the default language has no voice.
- `ConversationScreen`: after a reply is committed, read it when the switch is on, the voice exists, the app is in the foreground and the conversation is the current route.

## Tests

- The setting round-trips and defaults to off.
- With the switch on, a committed reply is spoken; with it off, nothing is.
- The Speech section shows the missing-voice line only when the voice is missing.

## Done when

- The tests pass and `scripts/check.sh` passes.
- On the Pixel, with the switch on, each reply is read once it arrives, and not when resuming a conversation. Checked by the user on 2026-09-27.
