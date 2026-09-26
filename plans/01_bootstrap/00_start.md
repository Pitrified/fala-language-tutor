---
status: done
priority: 0
description: |
  Bootstrap this repo from flutter-setup-project: the tutor with the cloud engine only, its
  tests and gates from the first commit, the LLM testing machinery copied in, and the product
  plan folders that were still open there, renumbered from 02.
---

# Bootstrap fala-language-tutor

Started 2026-09-26. Phases in [`tracking.md`](tracking.md).

## Where this came from

fala grew inside [flutter-setup-project](https://github.com/Pitrified/flutter-setup-project), a repo that began as a Flutter scaffolding exercise.
That repo is being split: it becomes a guide to setting up Flutter and a gallery of patterns other projects use, and the tutor moves here.
The split is planned in that repo's `plans/20_repo_split/`, whose audit (`02.1_audit_table.md` there) assigns every file a destination.

There is no bootstrap script. A Claude session reads this plan and the source repo and writes this one.
The session that wrote it also wrote the audit, so this plan is the record of what it assumed; a later session bootstrapping another app from the guide should not need that context.

## Source

- Repo: `Pitrified/flutter-setup-project`, branch `feat/20_repo_split` at `db87b69`.
  That branch carries a cleanup made for this split (unused code and dependencies removed, the OpenAI engine's schema made a parameter, `dart format` made a gate) which is not yet on its `main`.
- Rows taken: those marked `fala` or `both` in the audit table.

## Scope

- **Kept**: the tutor as it runs today with the OpenAI engine, the fake engine for tests, the streaming and structured-output path, conversations in Hive, the API key in secure storage, the settings, CEFR, topic and target-language pickers.
- **Removed**: the on-device engine. `flutter_gemma`, the model download screen, the model check at startup, `ModelConfig`, `ModelMetadata`, `ModelManager`, and the native-library excludes in the Android build.
- **Kept, simplified**: `AppController`. The audit put it on the guide side as on-device startup, but it also initializes whichever engine is selected, and the welcome screen and router depend on its state. Here it keeps loading, ready and error, and loses the model check.
- **Copied as is**: the LLM testing machinery (mock OpenAI server, `integration_test/`, `scripts/e2e.sh`, `tool/adb_ui.sh`), duplicated on purpose until a third app needs it.
- **Gates from the first commit**: `scripts/check.sh` with links, plans, codegen, format, analyze, test, the pre-commit hook, and the CI workflow at the same pinned Flutter version.
- **Same `applicationId`**, `com.fala.app`, so an install from either repo upgrades the other and the Play listing stays valid. The guide changes its own id.

## Plans

Numbered from 01 here (the source's Q8 in `20_repo_split/00_start.md`: "keep the new repo clean and renumber").
The source folders still open about the product move and are renumbered:

| Here | Source folder |
| ---- | ------------- |
| `02_release` | `07_release` |
| `03_ui_tweaks` | `09_ui_tweaks` |
| `04_key_distribution` | `13_key_distribution` |
| `05_audio_io` | `14_audio_io` |
| `06_apk_distribution` | `19_apk_distribution` |
| `07_dependency_upgrades` | `23_dependency_upgrades`, the fala half |

Links from them to folders that stay in the source become absolute links to the source repo on GitHub. Done folders stay in the source as its history.

## Out of scope

- Anything new in the product. The tutor behaves as it did in the source, minus the on-device engine.
- A cloud setup script; `docs/getting-started.md` carries the fresh-session note until one exists.
