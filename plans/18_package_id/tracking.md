# Android package id - implementation tracking

The Android package id moves from `com.fala.app` to `com.pitrified.fala`, before anything is uploaded to Play.

Analysis and decisions in [`00_start.md`](00_start.md).

## Phases

| #  | Phase | Plan | Status |
| -- | ----- | ---- | ------ |
| 01 | Rename the id | [`01_rename.md`](01_rename.md) | done |

Status values: draft / planned / in progress / done / superseded / discarded.

## Log

Append-only. Newest at the bottom.

- 2026-11-17 : open point left untracked by a session in unity-setup-project.
- 2026-11-17 : Q1 a and Q2 answered (user): coordinated with acerta-word-drills (`com.pitrified.acerta`) and flutter-setup-project (`com.pitrified.fluttersetup`). Nothing is on Play for any of them. The `v0.1.0` tag may have a GitHub release APK with the old id, which would not upgrade.
- 2026-11-17 : phase 01 done: id, Kotlin package folder, ProGuard rule and four docs renamed; `scripts/check.sh` passes (287 tests); release APK installed on the emulator as `com.pitrified.fala` and launched to the welcome screen. Folder done.
