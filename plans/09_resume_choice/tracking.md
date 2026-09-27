# Resume choice - implementation tracking

Offer "Resume conversation" or "New conversation" on a cold start with a last conversation that has messages.

Analysis and decisions in [`00_start.md`](00_start.md).

## Phases

| #  | Phase | Plan | Status |
| -- | ----- | ---- | ------ |
| 01 | Resume or new on a cold start | [`01_resume_or_new.md`](01_resume_or_new.md) | done |
| 02 | Welcome screen wording | [`02_welcome_polish.md`](02_welcome_polish.md) | done |

Status values: draft / planned / in progress / done / superseded / discarded.

## Log

Append-only. Newest at the bottom.

- 2026-09-27 : folder raised and phase 01 derived from `00_start.md` D1 to D3.
- 2026-09-27 : phase 01 built: `resumableConversation` in the controller, `ResumeChoice` in the body on a cold start. Controller and widget tests pass; stays in progress until the Pixel run.
- 2026-09-27 : Pixel run of 0.0.1+f9b03506 (user): topic length fine; the resume flow needs more UX polish, and the first change asked is phase 02: "Start learning" on the welcome button and no model line.
- 2026-09-27 : Pixel run of 0.0.1+c7453028 (user): "looks good". Phases 01 and 02 and the folder done.
