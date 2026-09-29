# Conversation history - implementation tracking

A Conversations page listing the saved conversations, with per-row delete and Clear all.

Analysis and decisions in [`00_start.md`](00_start.md).

## Phases

| #  | Phase | Plan | Status |
| -- | ----- | ---- | ------ |
| 01 | Names, list and deletion in the controller | [`01_controller.md`](01_controller.md) | planned |
| 02 | Conversations page | [`02_page.md`](02_page.md) | planned |

Status values: draft / planned / in progress / done / superseded / discarded.

## Log

Append-only. Newest at the bottom.

- 2026-09-29 : folder written from the user's request, after reading the conversation model, repository and controller.
- 2026-09-29 : D2 reopened, timestamp ids stay (no UUID); D5 confirmed.
- 2026-09-29 : last-used date, x without a dialog, all languages listed (user). No open questions.
