---
status: in progress
---

# 04 - Say it better

## Overview

The "say it better" idea from the draft, with `00_start.md` Q2: a setting turns it on for every reply; off, a button beside the reply bubble asks for it. On demand is a second request; automatic rides in the same structured response.

## Prompt lab

`tutor_response/v5.txt` is v4 plus a "Say it better" section filled from `better_rule` in `reply_style.json`. Run on the Lisbon conversation, 2026-09-28, gpt-5.4-nano and gpt-6-luna:

- With the rule off, `better` stayed empty on every turn of both models.
- First wording: gpt-6-luna rewrote each message richer ("estacionar por aqui custa os olhos da cara, e as ruas são estreitíssimas"); gpt-5.4-nano answered the learner in `better` on two turns of five and added a clause of its own once ("eu acabo repensando a ideia").
- Second wording, "rewritten, not a reply to it. Same speaker, same content, nothing added and nothing left out": gpt-5.4-nano kept to rewrites on every turn, often only a little richer than the correction. It left the greeting turn empty once at B1, as the rule allows.
- Reply level and timings as in phase 02; with the rule on, about 300 more output tokens over five turns.

## Change

- `TutorResponse.better` (content, translation), empty by default so saved replies still parse; in the schema.
- `v5.txt`, `better_rule` on and off in `reply_style.json`; `say_better/v1.txt` for the request on one reply, through the same schema.
- `say_better_auto` setting, `sayBetterAutoProvider`, a switch on the Language page.
- `ConversationController`: `better_rule` from the setting; `requestBetter` sends the learner message before a reply and its correction, and saves the answer on the reply (`ConversationRepository.replaceMessage`).
- Conversation screen: a "Say it better" card under a reply that has one, tap for the translation; a sparkle button above the speaker beside a reply that has none, with a spinner while it runs and a snackbar when there was nothing to improve or the request failed.
- The scroll test's fixture translation runs to four lines, because the two stacked buttons are taller than a one-line bubble and revealing a one-line translation no longer grew the row.
- The prompt lab summary lists the `better` of each turn.
- Docs: `functional-specs.md` (schema, screens, stored settings), `prompt-engineering.md` (Say it better).

## Tests

- A reply saved without `better` parses with it empty; `better` round-trips.
- The controller sends the off rule, then the on rule after the setting changes.
- `requestBetter` sends the learner message and reply level, saves the rewrite on the reply and keeps the reply; an unknown id gives null.
- Tapping the sparkle shows the card, and tapping the card its translation.

## Done when

- The tests pass and `scripts/check.sh` passes.
- On the Pixel: with the switch off, the sparkle brings a rewrite under the reply; with it on, rewrites come with the replies.
