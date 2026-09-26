---
status: done
---

# Phase 05 - Verify and push

## Plan

- `scripts/check.sh` in the working tree, then in a clean clone, which is the CI condition.
- Push, and read the CI result on GitHub.
- The on-device smoke test on the Pixel is handed back to the user.

## Done when

- A clean clone passes the gates, and CI's result on the pushed commit is read and recorded, whichever it is.

## What the implementation found

- `scripts/check.sh` passed in the working tree, then in a clean clone (`git clone --no-hardlinks`, no generated files, cold `.dart_tool`): all six gates, 166 tests, 1 min 56 s.
- CI run 1 on `feat/01_bootstrap` at `1446ada`, the first workflow run in this repo: `completed`, `success`.
- **Not done here:** running the tutor on the Pixel with a real key, and measuring the APK without `flutter_gemma`. Both need the workstation.
