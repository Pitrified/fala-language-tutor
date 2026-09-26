# Getting Started

Run the gates, the app and the end-to-end check for fala.
Setting up Flutter and the Android toolchain from zero, on a workstation or headless, is in the guide this repo was split from:
[flutter-setup-project, `docs/getting-started.md`](https://github.com/Pitrified/flutter-setup-project/blob/main/docs/getting-started.md).
This repo pins the same Flutter version in `.github/workflows/checks.yml`.

## Fresh cloud session

A claude.ai cloud session starts from a fresh clone on Ubuntu, as root, with no Flutter and no Android SDK.
Until the cloud environment runs a setup script, install Flutter by hand at the version CI pins, from the repo root:

```bash
version=$(sed -n 's/.*flutter-version: *//p' .github/workflows/checks.yml)
curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${version}-stable.tar.xz" \
  | tar -xJ -C "$HOME"
git config --global --add safe.directory '*'   # the SDK is a git checkout owned by another uid
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/flutter/bin:$PATH"
flutter --disable-analytics
scripts/check.sh
```

The SDK unpacks to about 2.3 GB and the first `pub get` adds about 700 MB, well inside the session's disk.
Claude's shell reads `~/.bashrc` for each command, so the `echo` line puts `flutter` on its `PATH` for the rest of the session; `scripts/check.sh` falls back to `$HOME/flutter/bin` either way.

What this does not give you:

- **The Android SDK.** No APK is built in a cloud session. Its command-line tools download from `dl.google.com`, which the default Trusted network access refuses.
- **Persistence.** The install lives in the session's container and is gone when the container is reclaimed. A new session repeats these steps.

## Project-specific setup

After cloning this repo:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
scripts/install-hooks.sh   # runs the gates on every commit
flutter run
```

## Gates

`scripts/check.sh` is the one command that runs every check: markdown links resolve,
the plan folders agree with their convention, codegen, `dart format`, `flutter analyze`, `flutter test`.
CI runs the same script, and `scripts/install-hooks.sh` points git at `.githooks` so a
commit runs it too (bypass with `git commit --no-verify`).

```bash
scripts/check.sh                   # one line per gate
scripts/check.sh -v                # every gate's full output
python3 scripts/gates/links.py     # one gate on its own
```

It is quiet by default: one line per gate, being that gate's own summary, and the
full output of any gate that fails. `-v` prints everything, which is worth it when
a gate passes and you still want to see what it did.

Gates run in this order: links, plans, codegen, format, analyze, test.
The format gate runs `dart format` over every Dart file git tracks or would add, untracked new files included and gitignored generated files skipped, and fails naming each file it would change.
Fix with `git ls-files -z --cached --others --exclude-standard -- '*.dart' | xargs -0 dart format`. Codegen is in the list
because `*.freezed.dart` and `*.g.dart` are gitignored, so a fresh checkout has
none and analyze fails on every freezed type. Warm it costs about 2s.

**Reproducing CI locally.** A pass on a working tree proves less than it looks:
your tree has generated files and a warm `.dart_tool` that a CI runner does not.
Clone the repo and run the gates in the clone, which is what CI checks out:

```bash
git clone --no-hardlinks . /tmp/fala-clean && cd /tmp/fala-clean
scripts/check.sh                   # ~2 min cold, mostly pub get and codegen
```

The workflow pins the same Flutter version this box runs, so the two are
comparable. Until that clone is green, CI is a guess.

## End-to-end on an emulator

`scripts/e2e.sh` is the slow check, kept out of `check.sh` because it takes minutes and needs an
emulator. It boots a headless AVD (`fala_api36`), starts the mock OpenAI server
(`tool/mock_openai.py`), and runs `integration_test/app_test.dart` against it, so a full conversation
is exercised with no API key and no network. Logs and the app's actual requests land in `build/e2e/`.

```bash
scripts/e2e.sh                     # reuse a running emulator, or boot one
scripts/e2e.sh --stop-emulator     # and shut it down afterwards
```

To drive the app by hand instead, `source tool/adb_ui.sh` gives `ui_tap`, `ui_text`, `ui_shot` and
friends, which find widgets in the view tree rather than guessing coordinates.

### How the app is pointed at the mock

`OPENAI_BASE_URL` is a compile-time define, read once in
`lib/services/inference/openai_inference_engine.dart` and empty by default, which
means the real API:

```bash
flutter run --dart-define=OPENAI_BASE_URL=http://10.0.2.2:8080/v1
```

- **It is a build-time define, not a Settings field.** A visible "API endpoint" box
  in a shipped app is a way to have someone's key sent elsewhere, and the value is a
  test fixture rather than a preference.
- **From an emulator the host is `10.0.2.2`**; `127.0.0.1` there is the emulator
  itself. `adb reverse tcp:8080 tcp:8080` makes `127.0.0.1` work too, on an emulator
  or a cabled phone.
- **Cleartext HTTP is debug-only**, granted by
  `android/app/src/debug/AndroidManifest.xml` and a network security config that
  permits `10.0.2.2`, `127.0.0.1` and `localhost`. Release builds stay strict.
- **The key goes in through the app's own Settings field.** The integration test
  types a dummy key and saves it, which exercises secure storage rather than adding
  a debug bypass to the one part of the app that handles a secret.

### What the mock does not prove

`tool/mock_openai.py` answers with scripted text whatever it is asked: it does not
validate the request against our JSON schema. So these runs prove the app handles a
well-formed OpenAI response, not that our `response_format` is one OpenAI accepts.
Only a real call with a real key proves that, and it stays a manual check.

The same reasoning keeps `scripts/e2e.sh` out of CI: a KVM-accelerated emulator in
GitHub Actions is slow and flaky, and `check.sh` has to stay fast enough that nobody
skips it.

## Target versions

| Concern | Value |
|---------|-------|
| Development API level | Android 16 (API 36) |
| Minimum release API | Android 8.0 (API 26) |
| Flutter channel | stable |
