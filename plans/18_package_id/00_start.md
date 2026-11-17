---
status: done
priority: 0
description: |
  Open point: the Android package id `com.fala.app` should probably be `com.pitrified.fala`.
  Decide before anything is uploaded to Play, where the id becomes permanent.
comment: |
  Left untracked from a session in unity-setup-project, 2026-11-17, picked up the same day.
---

# Android package id

Raised 2026-11-17 by the user while choosing the id for artificial-pirate (`com.pitrified.artificialpirate`):
"the prefix in fala is kinda random btw, it probably should be `com.pitrified.fala`? leave this as an open point in fala".
Nothing decided; no file in this repo was changed.

## Current state, read 2026-11-17

- `applicationId` and `namespace` are `com.fala.app` in `android/app/build.gradle.kts`; `MainActivity.kt` sits in `com/fala/app/`; `proguard-rules.pro` keeps `com.fala.app.MainActivity`.
- Also named in `docs/functional-specs.md`, `docs/build-and-release.md`, `docs/google-play-private-alpha.md`, `docs/prompt-engineering.md`, and the plans `01_bootstrap` and `02_release` (history, left as is).
- `02_release` is in progress with the Play Console steps outstanding, so nothing has been uploaded and the id is still free to change.
- Other repos on the box: `acerta-word-drills` uses `com.acerta.app`, the same pattern; `flutter-setup-project` (the guide) still has `com.fala.app` from before the split.

## What changing it means

- The id is permanent once an upload reaches Play; changing it after means a new app listing.
- An installed build with the old id stays on the device as a separate app, with its own data (settings, saved conversations, downloaded models); nothing migrates.
- The method channels (`fala/speech` and the one in `diagnostics_dump_provider.dart`) are named independently of the package and need no change.

## Open questions

- Q1: change the id?
  - a. `com.pitrified.fala` (namespace, `applicationId`, the Kotlin package folder, ProGuard rule, docs), before the Play upload.
  - b. keep `com.fala.app`.
  - ANS: a.
- Q2: if a, the same for `acerta-word-drills` (`com.pitrified.acerta`) and the guide's template id in `flutter-setup-project`?
  - ANS: yes, coordinated: `com.pitrified.acerta` in acerta-word-drills and `com.pitrified.fluttersetup` in flutter-setup-project.
    No underscore in the guide's id, since an iOS bundle id allows only letters, digits, hyphens and periods; it replaces the `com.pitrified.flutter_setup` that the guide's `20_repo_split/00_start.md` Q7 had chosen.
    Each repo changes on its own branch; nothing couples them except that no two may share an id.

## Decisions

- The id is `com.pitrified.fala` for `namespace` and `applicationId` alike, and the Kotlin package moves to `com/pitrified/fala/`.
- The signing key is independent of the id and stays.
- Plans keep the old id as history; docs and code carry the new one.
- An installed `com.fala.app` build on a phone is removed by hand (`adb uninstall com.fala.app`); its data does not carry over.
