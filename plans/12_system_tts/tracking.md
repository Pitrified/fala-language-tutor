# System text-to-speech - implementation tracking

Read the tutor's replies aloud with the phone's text-to-speech, on demand and automatically.

Analysis and decisions in [`00_start.md`](00_start.md).

## Phases

| #  | Phase | Plan | Status |
| -- | ----- | ---- | ------ |
| 01 | Speaker button on tutor replies | [`01_speaker_button.md`](01_speaker_button.md) | in progress |
| 02 | Read replies aloud automatically | [`02_auto_read.md`](02_auto_read.md) | in progress |

Status values: draft / planned / in progress / done / superseded / discarded.

## Log

Append-only. Newest at the bottom.

- 2026-09-27 : draft written from option O1 of the audio folder.
- 2026-09-27 : Q1 to Q7 answered (user); D1 to D6 folded in, phases 01 and 02 derived.
- 2026-09-27 : phases 01 and 02 built together, as they share the service and the conversation screen. `SpeechService` with `SystemSpeechService` (flutter_tts, start-guarded end events) and `FakeSpeechService`; `speechProvider`; `SpeakButton` and the missing-voice dialog; the `fala/speech` channel in `MainActivity`; the Speech section on the Language page. New tests for the text cleanup, the provider, the button and dialog, send and auto-read on the conversation screen, the lifecycle stop, the setting and the Speech section. Three mutations seen failing: no stop on send, stopping on `inactive` instead of `hidden`, no generation guard. The test binding starts with no lifecycle state, so the screen tests set `resumed` first. Docs: the screen list, stored settings and the privacy policy. `scripts/check.sh` passes; both phases stay in progress until the Pixel run.
