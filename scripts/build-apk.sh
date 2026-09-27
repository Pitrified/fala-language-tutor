#!/usr/bin/env bash
# Build the APK with the version label the app shows in its drawer: the
# version name from pubspec.yaml and the first eight characters of the commit.
# A tree with uncommitted changes gets "-dirty", so a label always names what
# was built.
#
#   scripts/build-apk.sh                 release, split per ABI, arm64 and x86_64
#   scripts/build-apk.sh --debug         any other flutter build apk flags
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

version=$(sed -n 's/^version: *\([^+]*\).*/\1/p' pubspec.yaml)
commit=$(git rev-parse --short=8 HEAD)
if [[ -n "$(git status --porcelain)" ]]; then
  commit="$commit-dirty"
fi

args=("$@")
if [[ ${#args[@]} -eq 0 ]]; then
  args=(--release --split-per-abi --target-platform android-arm64,android-x64)
fi

echo "building $version+$commit"
flutter build apk "${args[@]}" \
  --dart-define=APP_VERSION="$version" \
  --dart-define=GIT_COMMIT="$commit"
