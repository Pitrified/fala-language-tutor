# Topic handling - implementation tracking

Remember recent custom topics in the picker, and show on a new conversation that its topic carried over from the last one.

Analysis and decisions in [`00_start.md`](00_start.md).

## Phases

| #  | Phase | Plan | Status |
| -- | ----- | ---- | ------ |
| 01 | Recent custom topics in the picker | [`01_recent_topics.md`](01_recent_topics.md) | done |
| 02 | A carried-over topic is marked on the new conversation | [`02_carried_over_marker.md`](02_carried_over_marker.md) | in progress |

Status values: draft / planned / in progress / done / superseded / discarded.

## Log

Append-only. Newest at the bottom.

- 2026-09-27 : Q1 to Q5 answered; phases 01 and 02 derived from Q1 and from Q3 with Q4.
- 2026-09-27 : phase 01 done: the picker lists the last five custom topics under "Recent", each removable; stored as `recent_topics` in the settings box. Tested in widget tests, not yet on the Pixel.
