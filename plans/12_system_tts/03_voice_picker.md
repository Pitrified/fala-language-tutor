---
status: in progress
---

# 03 - Engine and voice picker

## Overview

`00_start.md` D7 and Q8: pick the text-to-speech engine and, per language, the voice, from the Speech section. Network voices are listed too, marked "online".

## Change

- `SpeechService`: `engines()`, `voices(TargetLanguage)`, and `speak` takes the engine and voice to use. A voice is a small model with its name, locale and whether it needs the network.
- `SystemSpeechService`: `getEngines`, `getVoices` filtered to the language's locale, `setEngine` when the engine changed, `setVoice` when a voice is set, `setLanguage` otherwise. A stored engine or voice that is gone falls back to the default with a warning.
- `AppSettingsRepository`: `speech_engine`, and `speech_voice_<code>` per language. Unset means the default.
- Language page, Speech section: "Engine" and "Voice" dropdowns under the switch. A voice with `network_required` is labelled "online". Changing either stops any speech and plays nothing by itself.
- Privacy policy: "Reading replies aloud" already says, since 2026-09-28, that a network voice sends the reply text to the engine's maker. This phase changes where the engine and voice are chosen, from Android settings to the Speech section, and names the "online" label.
- `FakeSpeechService`: canned engines and voices, and records the engine and voice of each `speak`.

## Tests

- The settings round-trip and default to unset.
- The dropdowns list the fake's engines and the voices of the current language only, with network voices labelled "online".
- A reply is spoken with the chosen engine and voice; with the stored voice missing, with the default.
- Changing the language shows that language's stored voice.

## Done when

- The tests pass and `scripts/check.sh` passes.
- On the Pixel, a sherpa-onnx engine app appears in the Engine list once installed, and choosing it and one of its voices changes what the speaker button plays.
