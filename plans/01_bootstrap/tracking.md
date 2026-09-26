# Bootstrap - implementation tracking

This repo written from flutter-setup-project with the tutor on the cloud engine only. Scope and source commit in [`00_start.md`](00_start.md).

## Key decisions

- **Written, not extracted.** No history carried over; the source keeps its own.
- **Cloud engine only.** `AppController` stays, without the model check.
- **Same `applicationId`**, `com.fala.app`.
- **Plans numbered from 01**; open product folders renumbered from 02.

## Phases

| #  | Phase                          | Plan                                       | Status      |
| -- | ------------------------------ | ------------------------------------------ | ----------- |
| 01 | Copy the baseline              | [`01_baseline.md`](01_baseline.md)         | done        |
| 02 | Cut the on-device engine       | [`02_cloud_only.md`](02_cloud_only.md)     | done        |
| 03 | Docs and instructions          | [`03_docs.md`](03_docs.md)                 | done        |
| 04 | Move the open plan folders     | [`04_plans.md`](04_plans.md)               | done        |
| 05 | Verify and push                | [`05_verify.md`](05_verify.md)             | in progress |

Status values: draft / planned / in progress / done / superseded / discarded.

## Log

Append-only. Newest at the bottom.

- 2026-09-26 : repo created empty by the user; this plan written by the session that ran the source's audit.
- 2026-09-26 : phase 1 - source tree at `db87b69` copied with `git archive`, minus its plans and the non-code guide rows; links to guide-only docs made absolute; the format gate extended to untracked files here and in the source. All gates pass, 168 tests.
- 2026-09-26 : phase 2 - on-device engine removed: five source files, the model download route, `flutter_gemma` and `path_provider`, the Android excludes for it; `AppController` kept without the model check. All gates pass, 166 tests.
- 2026-09-26 : phase 3 - README, instructions and twelve docs rewritten or edited for the cloud engine only. The privacy policy changed and its hosted copy needs updating before a release. APK size left unmeasured.
- 2026-09-26 : phase 4 - open product folders moved and renumbered 02 to 07, links rewritten, a move note at the top of each.
