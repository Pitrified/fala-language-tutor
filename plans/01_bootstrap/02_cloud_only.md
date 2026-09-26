---
status: done
---

# Phase 02 - Cut the on-device engine

## Overview

Remove everything that exists only for the on-device engine, and simplify what was shaped around it.

## Plan

- Delete `flutter_gemma_engine.dart`, `model_download/`, `model_config.dart`, `model_metadata.dart`, `model_manager.dart`, and their docs.
- `EngineKind`: `fake` and `openai`. A stored `gemma` from an earlier install falls back to the default, `openai`, which `AppSettingsRepository.engineKind` already does for any unknown name.
- `EngineFactory` takes no model path. `AppController` loses the model check, `AppNeedsModel` and `onModelDownloaded`; `AppReady` loses `modelInfo`.
- Router: no model-download route or redirect. Welcome screen: no model-download branch.
- `main.dart`: no `FlutterGemma.initialize()`.
- `pubspec.yaml`: drop `flutter_gemma` and `path_provider`. Android: drop the `jniLibs` excludes that exist for `flutter_gemma`.
- Tests follow.

## Done when

- `grep -ri gemma` over `lib/`, `test/`, `android/` and `pubspec.yaml` finds nothing.
- `scripts/check.sh` passes.

## What the implementation found

- **Also went:** `modelManagerProvider` in `service_providers.dart`, the `model_metadata` export in `models.dart`, and stale comments naming the on-device engine in the engine interface, the OpenAI engine and the settings screen.
- **`EngineFactory` takes no argument now**; the fake engine's factory is its constructor tear-off.
- **Android:** the `flutter_gemma` native-library excludes went; the `armeabi-v7a` exclude stayed, since the 64-bit-only build is a decision of its own in `docs/build-and-release.md`.
- **Upgrades from an install with the on-device engine:** the stored engine name `gemma` no longer maps to a kind, and `AppSettingsRepository.engineKind` already falls back to the default, OpenAI, for any unknown name. A test now pins that case by name.
- **Tests:** 168 to 166. The registry lost its gemma and model-check tests, the controller lost the two model-download tests and gained one for retrying after an error, and settings gained the `gemma` fallback test.
- `pub get` changed 21 dependencies, the transitive tree of `flutter_gemma` and `path_provider`.
- `grep -ri gemma` over `lib/`, `android/`, `integration_test/` and `pubspec.yaml` finds nothing; in `test/` only the fallback test names it.
