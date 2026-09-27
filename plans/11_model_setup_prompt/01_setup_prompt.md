---
status: done
---

# 01 - Setup prompt, banner and source link

## Overview

`00_start.md` D1 to D5 in one phase: they share the provider and are small.

## Change

- `engine_kind.dart`: `requiresKey`.
- `settings_provider.dart`: `apiKeyPresentProvider` and `modelSetupNeededProvider`.
- `model_settings_screen.dart`: invalidate `apiKeyPresentProvider` after save and clear.
- `welcome_screen.dart`: "Setup model" or "Start learning" once ready, nothing while the key store has not answered.
- `conversation_screen.dart`: `ModelSetupBanner` at the top of the body while setup is needed; `SourceLink` above the version line in the drawer.
- `build_info.dart`: `sourceRepoUrl`.
- `pubspec.yaml`: `url_launcher`; `AndroidManifest.xml`: the https VIEW query.
- `docs/functional-specs.md`: the screen inventory and the missing-key row of the error table.

## Tests

- `test/providers/model_setup_needed_test.dart`: unknown before the key store answers, needed for OpenAI without a key, flips when the key is written and cleared, never needed for the fake engine.
- `welcome_screen_test.dart`: fake engine and OpenAI with a key show "Start learning"; OpenAI without one shows "Setup model", which opens the Model page.
- `model_setup_banner_test.dart`: the icon and text, and the tap opens the Model page.
- The scroll tests pin `modelSetupNeededProvider` to false; they are about scrolling.

## Done when

- The tests pass and `scripts/check.sh` passes.
- On the Pixel: a fresh install (or cleared key) shows "Setup model"; saving a key turns it into "Start learning"; clearing the key shows the red strip in the conversation; "Source: fala" opens the repository in the browser. Checked by the user on 2026-09-27.
