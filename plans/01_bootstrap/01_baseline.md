---
status: done
---

# Phase 01 - Copy the baseline

## Overview

The source tree as it is at `db87b69`, minus its plans and the files the audit marks `guide` that are not code: the VS Code workspace, the AI playbook, `docs/guides/` and the runtime model manager doc.
The guide-only code stays for this phase so the app still builds and runs with the on-device engine; phase 02 removes it, so that phase's diff shows exactly what went.

## Plan

- Copy the tracked files, not the working tree, with `git archive` from the source commit, then delete the source's plan folders and the non-code `guide` rows. The `drop` rows were already deleted in the source.
- Keep the source's `plans.py` as this repo's vendored copy.

## Done when

- `scripts/check.sh` passes in this repo with nothing changed but the file set.

## What the implementation found

- The baseline built and all 168 tests passed as copied. Two gates failed on the copy itself.
- **Links:** nine links pointed at docs that stay in the source (the AI playbook, the model-management guide, the runtime model manager doc). They now point at those files on the source's `main` on GitHub; phase 03 removes the on-device ones.
- **Format:** the gate listed only tracked files, and with nothing committed yet `dart format` got no paths and failed. The gate now also covers untracked files that are not ignored, which closes a real hole in both repos: a new file escaped the gate until it was committed. Changed in the source too (`67311cb` there), and seen failing on an untracked misformatted file before passing.
