# Model setup prompt - implementation tracking

Send a user without an API key to the Model page, and link the source repository from the drawer.

Analysis and decisions in [`00_start.md`](00_start.md).

## Phases

| #  | Phase | Plan | Status |
| -- | ----- | ---- | ------ |
| 01 | Setup prompt, banner and source link | [`01_setup_prompt.md`](01_setup_prompt.md) | done |

Status values: draft / planned / in progress / done / superseded / discarded.

## Log

Append-only. Newest at the bottom.

- 2026-09-27 : folder raised from the user's request; `url_launcher` approved and the repository confirmed public in the same exchange. D1 to D5 settled, phase 01 derived.
- 2026-09-27 : phase 01 built. `modelSetupNeededProvider`, "Setup model" on the welcome screen, `ModelSetupBanner`, `SourceLink`. New tests: the provider (unknown, needed, flips on write and clear), the welcome button in three cases, the banner's navigation. `scripts/check.sh` passes; stays in progress until the Pixel run.
- 2026-09-27 : Pixel run of 0.0.1+433ecf3c (user): "works". Phase 01 and the folder done.
