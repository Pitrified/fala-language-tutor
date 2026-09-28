---
status: done
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

## Result

Run on the Pixel 7 Pro on 2026-09-28 (user), pt-BR, with the engine and voice picker and the Diagnostics page of `12_system_tts`. Candidates: Google's local voices `pt-BR-language`, `pt-br-x-afs-local`, `pt-br-x-ptd-local`, `pt-br-x-pte-local`, and SherpaTTS with Piper `pt_BR-dii-high`. Only Piper was tried among the neural models, since SherpaTTS offers Piper and Coqui voices.

- By ear: Sherpa dii-high "wins by like a fraction. Good enough to have the external app, not good enough to have the full sherpa onnx" (user).
- Time to first sound, 70-character reply: Sherpa 117 ms; Google 112 to 260 ms, `afs` 797 ms. The first play after switching engine or voice took 900 ms or more.

Outcome: the second one listed above, in its SherpaTTS form. The external SherpaTTS app, chosen in fala's Engine list, is good enough; building sherpa-onnx into fala is not worth it for this gain.
