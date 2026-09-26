---
status: in progress
---

# Phase 05 - Verify and push

## Plan

- `scripts/check.sh` in the working tree, then in a clean clone, which is the CI condition.
- Push, and read the CI result on GitHub.
- The on-device smoke test on the Pixel is handed back to the user.

## Done when

- A clean clone passes the gates, and CI's result on the pushed commit is read and recorded, whichever it is.
