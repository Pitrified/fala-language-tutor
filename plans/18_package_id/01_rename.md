---
status: done
---

# 01 - Rename the id

## Goal

The app builds and installs as `com.pitrified.fala`, and nothing outside `plans/` names `com.fala.app`.

## Plan

- `android/app/build.gradle.kts`: `namespace` and `applicationId`.
- `MainActivity.kt` moves to `android/app/src/main/kotlin/com/pitrified/fala/`, with its `package` line.
- `android/app/proguard-rules.pro`: the keep rule for `MainActivity`.
- Docs: `functional-specs.md`, `build-and-release.md`, `google-play-private-alpha.md`, `prompt-engineering.md`.

## Done when

- `grep` finds no `com.fala.app` outside `plans/`.
- `scripts/check.sh` passes.
- A release APK installs on the emulator as `com.pitrified.fala` and launches to its welcome screen.

## What the implementation found

- The release build needs `JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64` on the dev box: the default JDK 25 there has no compiler, and Gradle fails before compiling. Unrelated to the id.
