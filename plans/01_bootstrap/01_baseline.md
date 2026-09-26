---
status: in progress
---

# Phase 01 - Copy the baseline

## Overview

Every file the audit marks `fala` or `both`, as it is in the source at `db87b69`, except the plans. The app still carries the on-device engine at the end of this phase; phase 02 removes it, so the diff of that phase shows exactly what went.

## Plan

- Copy the tracked files, not the working tree, with `git archive` from the source commit, then delete the `guide` and `drop` rows and all of `plans/`.
- Keep the source's `plans.py` as this repo's vendored copy.

## Done when

- `scripts/check.sh` passes in this repo with nothing changed but the file set.
