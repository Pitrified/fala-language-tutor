---
status: planned
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
