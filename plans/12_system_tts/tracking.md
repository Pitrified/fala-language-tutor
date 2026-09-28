# System text-to-speech - implementation tracking

Read the tutor's replies aloud with the phone's text-to-speech, on demand and automatically.

Analysis and decisions in [`00_start.md`](00_start.md).

## Phases

| #  | Phase | Plan | Status |
| -- | ----- | ---- | ------ |
| 01 | Speaker button on tutor replies | [`01_speaker_button.md`](01_speaker_button.md) | done |
| 02 | Read replies aloud automatically | [`02_auto_read.md`](02_auto_read.md) | done |
| 03 | Engine and voice picker | [`03_voice_picker.md`](03_voice_picker.md) | in progress |
| 04 | Speech diagnostics page | [`04_speech_diagnostics.md`](04_speech_diagnostics.md) | in progress |

Status values: draft / planned / in progress / done / superseded / discarded.

## Log

Append-only. Newest at the bottom.

- 2026-09-27 : draft written from option O1 of the audio folder.
- 2026-09-27 : Q1 to Q7 answered (user); D1 to D6 folded in, phases 01 and 02 derived.
- 2026-09-27 : phases 01 and 02 built together, as they share the service and the conversation screen. `SpeechService` with `SystemSpeechService` (flutter_tts, start-guarded end events) and `FakeSpeechService`; `speechProvider`; `SpeakButton` and the missing-voice dialog; the `fala/speech` channel in `MainActivity`; the Speech section on the Language page. New tests for the text cleanup, the provider, the button and dialog, send and auto-read on the conversation screen, the lifecycle stop, the setting and the Speech section. Three mutations seen failing: no stop on send, stopping on `inactive` instead of `hidden`, no generation guard. The test binding starts with no lifecycle state, so the screen tests set `resumed` first. Docs: the screen list, stored settings and the privacy policy. `scripts/check.sh` passes; both phases stay in progress until the Pixel run.
- 2026-09-27 : Pixel run of 0.0.1+8a7056df (user): all four checks confirmed (speaker plays and stops, auto-read, leaving the app stops it, missing-voice dialog and install screen). Phases 01 and 02 and the folder done.
- 2026-09-28 : reopened for the listening test of `13_neural_tts` (its D2). D7 to D9 and Q8 written; phases 03 (engine and voice picker) and 04 (speech diagnostics) derived.
- 2026-09-28 : Q8 answered (user): network voices listed, marked "online". Privacy policy updated the same day: network voices send the reply text to the engine's maker, and a line not to type secrets into the chat.
- 2026-09-28 : phases 03 and 04 built in four pushed steps. 03: `SpeechService` gains `engines`, `voices` and engine and voice arguments to `speak` (flutter_tts `setEngine`, `setVoice`, falling back to `setLanguage`); `speech_engine` and `speech_voice_<code>` settings; Engine and Voice dropdowns in the Speech section, network voices marked "online". 04: `DiagnosticsLog` (Hive box `diagnostics`, newest 500 lines), one line per utterance from `SpeechNotifier.play` with trigger, timings from the engine's start event and the outcome that `speak` now returns, plus a line per engine or voice change; `deviceInfo` on the `fala/speech` channel; the Diagnostics page with Copy and Clear. A mutation (voice not passed to `speak`) was seen failing the picker test. Docs: screens, persistence, privacy policy. Both phases stay in progress until the Pixel run.
