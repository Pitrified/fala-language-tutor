---
status: in progress
---

# 04 - Speech diagnostics page

## Overview

`00_start.md` D8 and D9: a log of what speech did, and a page that dumps it as text for pasting back, with the metadata filled in.

## Change

- `lib/services/diagnostics/`: `DiagnosticsLog` over a Hive `Box<String>`, one line per entry, capped at the newest 500. `add(kind, fields)` and `dump()`.
- `SpeechNotifier`: one entry per utterance, with trigger, language, engine, voice, text length, milliseconds to start, milliseconds speaking and the outcome. Timing comes from the start and end events the service already has. Engine and voice changes are entries too.
- `MainActivity.kt`: `deviceInfo` on the `fala/speech` channel, returning maker, model, Android release and SDK level. No new dependency.
- `DiagnosticsScreen` at `/settings/diagnostics`: the metadata header and the log as selectable monospace text, with "Copy" (to the clipboard, then a snackbar) and "Clear". A "Diagnostics" entry after Model in `SettingsEntries`.
- Docs: the screen list, the stored data, and a privacy policy line saying the log stays on the phone and holds no message text.

## Example dump

```
fala diagnostics 2026-09-28T18:04:11+02:00
app 0.0.1+1a2b3c4d | Google Pixel 8 | Android 16 (SDK 36)
language pt-BR | level B1 | inference openai | read aloud on
speech engine com.google.android.tts | voice pt-br-x-afs-local
engines com.google.android.tts, com.k2fsa.sherpa.onnx.tts.engine
--
18:01:02 speak button pt-BR com.google.android.tts pt-br-x-afs-local chars=142 start_ms=310 speak_ms=9120 finished
18:01:40 engine com.k2fsa.sherpa.onnx.tts.engine
18:01:52 speak button pt-BR com.k2fsa.sherpa.onnx.tts.engine default chars=142 start_ms=1480 speak_ms=8650 stopped
```

The engine package names and numbers above are made up to show the shape.

## Tests

- The log caps at 500 and keeps the newest.
- An utterance that finishes, one that is stopped and one that errors each write one line with the right outcome and timings (fake clock).
- The page shows the header and the lines, "Copy" puts the same text on the clipboard, "Clear" empties it.
- No entry contains the spoken text.

## Done when

- The tests pass and `scripts/check.sh` passes.
- On the Pixel, a release APK's dump after a few replies pastes back with every field filled in.
