---
status: in progress
---

# 01 - First GitHub release, v0.1.0

## Goal

`v0.1.0` on the repository's Releases page with the release-signed arm64 APK attached, installed on the Pixel from that page.

## Prep, in a cloud session

- `pubspec.yaml` version `0.0.1+1` to `0.1.0+2`.
- Release notes in `docs/releases/0.1.0.md`, used as the release body.
- "GitHub release" section in `docs/build-and-release.md`: keystore once, signed build, signature check, tag and upload, install on the phone.

## On g7, by the user

1. Create the keystore and `android/key.properties` (`docs/build-and-release.md`, "Production signing"). Back up the `.jks` and both passwords outside the repo.
2. Pull main, run `scripts/build-apk.sh` on a clean tree.
3. `apksigner verify --print-certs` on the arm64 APK shows the new certificate, not "Android Debug".
4. `gh release create v0.1.0` with the APK and the notes, or the web form.
5. On the Pixel: uninstall the debug build, download from the release page, install.

## Done when

- The release page lists `v0.1.0` with `fala-0.1.0-arm64.apk`.
- The Pixel runs it, showing `0.1.0+<commit>` in the drawer. Checked by the user.
