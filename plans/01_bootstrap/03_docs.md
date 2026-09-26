---
status: done
---

# Phase 03 - Docs and instructions

## Plan

- `README.md`, `CLAUDE.md`, `.github/copilot-instructions.md`: about the tutor on the cloud engine; the generic sections (gates, how to write, planning, diary rule) kept.
- `docs/functional-specs.md`, `docs/library/*`, `docs/build-and-release.md`, `docs/getting-started.md`: no on-device engine. `getting-started.md` keeps the fresh-session note, the gates and the e2e section, and points at the guide for setting up Flutter from zero.
- `docs/ai-development-playbook.md` stays in the guide; this repo links to it.

## Done when

- No doc describes the on-device engine as part of this app.
- The link gate passes.

## What the implementation found

- **Rewritten:** `README.md`, the overview, stack and hard rules in `.github/copilot-instructions.md`, `docs/library/app-controller.md` (three states, no model check), and `docs/getting-started.md`, cut to the fresh-session note, project setup, gates, the e2e check and target versions, with setup from zero linked to the guide.
- **Edited for the cloud-only app:** functional specs (decisions, platform constraints, lifecycle, screens, persistence, error handling, out of scope), the engine doc, the prompt doc (the small-model and Qwen sections replaced by what the strict schema does and does not constrain), the build doc, the Play doc, the structure doc.
- **The privacy policy changed.** It offered the on-device model as the way to keep data on the device, which is no longer true. It now says replies come from OpenAI, and its date is 2026-09-26. The copy the Play listing links to has to be updated where it is hosted before the next release.
- **The APK size is unknown.** The last measurement included `flutter_gemma`; the build doc says so rather than quoting a number, until a machine with the Android SDK builds it.
- **The instructions gained a "cloud session" machine**, headless and able to push.
