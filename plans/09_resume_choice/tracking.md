# Resume choice - implementation tracking

Offer "Resume conversation" or "New conversation" on a cold start with a last conversation that has messages.

Analysis and decisions in [`00_start.md`](00_start.md).

## Phases

| #  | Phase | Plan | Status |
| -- | ----- | ---- | ------ |
| 01 | Resume or new on a cold start | [`01_resume_or_new.md`](01_resume_or_new.md) | in progress |

Status values: draft / planned / in progress / done / superseded / discarded.

## Log

Append-only. Newest at the bottom.

- 2026-09-27 : folder raised and phase 01 derived from `00_start.md` D1 to D3.
- 2026-09-27 : phase 01 built: `resumableConversation` in the controller, `ResumeChoice` in the body on a cold start. Controller and widget tests pass; stays in progress until the Pixel run.
