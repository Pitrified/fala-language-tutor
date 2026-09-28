---
status: planned
---

# 01 - Listening test on the Pixel

## Overview

`00_start.md` Q5 and D2: hear the candidates inside fala on the same replies, and time them with the diagnostics page, before any neural code or dependency.

Waits on phases 03 (engine and voice picker) and 04 (speech diagnostics) of `12_system_tts`.

## Candidates

For pt-BR and es-ES each:

- The Google engine's default voice, as the baseline, and its other voices for the language.
- A sherpa-onnx engine app installed on the Pixel, with each model it offers for the language. Piper (M1) has pt-BR and es-ES voices. Whether an engine app offers Kokoro (M2) or Supertonic (M3) is not known from here; the phase records what it found.

## Steps

The user runs these; nothing is built in this phase.

1. Install a sherpa-onnx engine app from its APK page (Sources in `00_start.md`), with the pt-BR and es-ES models it has.
2. In fala, Language page, Speech section: pick an engine and a voice.
3. Play the same three tutor replies per language with the speaker button: one short, one long, one with numbers or names.
4. Repeat for each engine and voice.
5. Open Diagnostics, copy the dump, and paste it back with a ranking by ear and one line per voice on what was wrong with it.

## Done when

- A ranking per language is recorded in `tracking.md`, with the dump's timings: time from tap to first sound, and speaking time per reply.
- One outcome is written down:
  - a neural model wins clearly and runs close to real time, and the next phases (runtime, download, replacement) are derived from D3 to D6;
  - a system voice picked with phase 03 of `12_system_tts` is good enough, and this folder stops there;
  - nothing on the phone is good enough, and the cloud voices in `05_audio_io` are the next place to look.
