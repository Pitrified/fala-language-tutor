---
status: draft
priority: 0
description: |
  Replace or supplement the phone's text-to-speech voice with a neural voice model that fala
  ships and runs on the device: which models, how they reach the phone, how they plug in.
---

# On-device neural voices

Spun off on 2026-09-28 from [`../12_system_tts/00_start.md`](../12_system_tts/00_start.md), after the system voice turned out robotic on the Pixel.
[`../05_audio_io/00_start.md`](../05_audio_io/00_start.md) stays the home of speech input and of the cloud and self-hosted voices.

Status: research. Nothing implemented, no phases derived.

## Where this came from

"We want a new spin off folder with research on a custom on device tts model. The current one default is very robotic. What are the options? How to integrate it?" (user, 2026-09-28)

## What the code gives us today

- Speech sits behind `SpeechService` (`isVoiceAvailable`, `speak`, `stop`, `openVoiceInstall`), with `SystemSpeechService` over `flutter_tts` and `FakeSpeechService` for tests. A second implementation slots in without touching the screens.
- `speakableText()` already strips emoji and markdown before anything is spoken.
- The five target languages are `pt-BR`, `es-ES`, `fr-FR`, `it-IT`, `de-DE`. Any model has to be judged on all five, and on `pt-BR` first.
- fala has no download screen and no on-device model today: the openai engine is the default and the fake engine is for tests. Anything here is the first large file the app fetches.
- The build is split per ABI and only arm64 matters for the Pixel.

## Checked from here and not

Facts below come from the upstream pages listed under Sources, read on 2026-09-28.
Hugging Face and the sherpa-onnx docs site are blocked from this box, so model file sizes, per-voice licences and Kokoro's per-voice quality grades were not read.
Nothing has been listened to or timed: every quality and speed statement is the upstream claim until the spike in the last section runs on the Pixel.

## Before any model: the system engine

- **O0a. Pick a better system voice.** Google's engine on the Pixel ships several voices per locale, and `flutter_tts` can list and set them. A voice picker in the Speech section costs no dependency. Some Google voices are network voices, which send the text to Google; the picker would have to mark or hide those.
- **O0b. Install a neural engine as the phone's TTS engine.** sherpa-onnx publishes Android TTS engine APKs, and SherpaTTS is a packaged one. Once set as the default engine in Android settings, fala's existing speaker button uses it with no code change. This is a user-side fix rather than a feature, but it is the cheapest way to hear the models below inside fala.

## Model options

| Option | Languages of ours | Weights licence | Phonemizer | Notes |
| --- | --- | --- | --- | --- |
| M1. Piper (VITS) | all five: pt-BR cadu, faber, jeff (medium), es-ES davefx, sharvard (medium), fr-FR siwis, tom, upmc (medium), it-IT paola (medium), de-DE thorsten (up to high) | per voice, in each voice's MODEL_CARD | espeak-ng | One small model per voice. The original repo was archived in October 2025 (MIT); development continues as `piper1-gpl` under GPL-3.0. The runtime we would use is sherpa-onnx, not Piper's own. |
| M2. Kokoro-82M | pt-BR (1 female, 2 male), es (1F, 2M), fr (1F), it (1F, 1M); no German in the base model | Apache-2.0 | espeak-ng | One multilingual model, voices as style vectors. Upstream grades non-English voices by their training data; the grades were not read from here. German only through community fine-tunes. |
| M3. Supertonic 3 | 31 languages including Portuguese, Spanish, French, Italian, German | code MIT, weights OpenRAIL-M | own text frontend, no espeak-ng | About 99M parameters, 44.1 kHz output. Portuguese is listed once; whether it speaks Brazilian or European Portuguese is unknown. The upstream repo now sits under an `oss-archive` organisation, so further releases are not expected. sherpa-onnx packages an int8 build. |
| M4. Meta MMS-TTS | all five | CC-BY-NC-4.0 | none | Non-commercial licence. Listed to rule out. |
| M5. Larger open models (XTTS-v2, Chatterbox, F5-TTS, Orpheus) | varies | varies, XTTS-v2 non-commercial | varies | Hundreds of millions to billions of parameters. Too large and too slow for a phone next to a chat app. Listed to rule out. |

## Runtime

- **R1. `sherpa_onnx` Flutter package** (Apache-2.0, Android arm64 included, 1.13.8 at the time of writing). One runtime for M1, M2 and M3, so the model choice can change later without changing the runtime. It returns PCM samples; playing them is on us (below). A new dependency, so it needs approval.
- **R2. `onnxruntime` binding plus our own frontend.** Only worth it for M3, whose frontend is plain text processing; M1 and M2 need espeak-ng anyway. More code for no gain over R1 unless R1's size or licence rules it out.

espeak-ng is GPL-3.0, and sherpa-onnx builds it in for Piper and Kokoro. The fala repo has no LICENSE file. Whether shipping an APK with espeak-ng linked in obliges fala to publish under the GPL is a question for the owner, not something to guess here (Q3). M3 avoids the question.

## How the model reaches the phone

- **D1. Bundled in the APK.** Works offline from install. Grows every download by the model size, for every language, whether the learner uses it or not.
- **D2. Downloaded on demand per language** from a pinned URL with a SHA-256 check, the first time the learner turns the neural voice on. The file could be mirrored as a release asset on the fala repo, so the URL stays under our control. Needs a small download UI (progress, cancel, retry, delete) and a privacy policy line for the fetch; the spoken text itself never leaves the phone.
- **D3. Play Asset Delivery on-demand packs.** Play installs only; the sideloaded APK used for testing would not have them.

## How it plugs in

- A `NeuralSpeechService` implements `SpeechService`. `isVoiceAvailable` means "model for this language is downloaded"; `openVoiceInstall` opens our download page instead of Android's.
- Synthesis runs in a background isolate, since the FFI call blocks. Text is split into sentences and each is played as soon as it is synthesized, so the first sentence starts before the reply is fully rendered to audio.
- Playback, one of:
  - **P1.** Write each sentence to a temporary WAV and play it with an audio package (`just_audio` or `audioplayers`, another dependency).
  - **P2.** Stream PCM to an `AudioTrack` through the existing `fala/speech` method channel in `MainActivity`. No dependency; we write the audio focus handling ourselves.
- Stopping keeps the `12_system_tts/00_start.md` D5 rules: `stop()` cancels the synthesis loop and the playback, and every trigger that stops the system voice stops this one.
- Selection, one of:
  - **S1.** The neural voice replaces the system voice for languages whose model is downloaded, and the system voice stays as the fallback.
  - **S2.** A "Voice: Phone / fala" choice in the Speech section, per language.
- Tests keep `FakeSpeechService`; the download manager gets a fake HTTP client, like every other test avoids the network.

## Costs to measure, not guess

- APK growth from the sherpa-onnx native libraries for arm64.
- Model size per language on disk and to download.
- Time from tap to first sound, and real-time factor, for a typical reply on the Pixel.
- Memory while speaking.

## Proposed first step

A listening test with no app code. Install a sherpa-onnx TTS engine APK on the Pixel with each candidate model it offers, set it as the phone's default engine, and use fala's speaker button on the same pt-BR replies. That ranks M1, M2 and M3 by ear inside the real app and tells us whether the gain over the system voice is worth an integration at all.
If one wins, a throwaway Flutter build with `sherpa_onnx` measures the costs above before anything is designed.

## Open questions

- Q1: Which languages must a neural voice cover at first: pt-BR only, or all five? Kokoro has no German, and Supertonic's Portuguese may be European.
  ANS: ...
- Q2: Is a one-time model download per language (D2) acceptable, or must a voice work offline from install (D1)?
  ANS: ...
- Q3: fala has no licence file. Is linking GPL-3.0 espeak-ng acceptable (M1, M2), or does that rule them out and leave M3?
  ANS: ...
- Q4: Does the neural voice replace the system one where available (S1), or is it a per-language choice (S2)?
  ANS: ...
- Q5: Run the no-code listening test on the Pixel first, before any dependency or phase?
  ANS: ...

## Sources

- sherpa-onnx: https://github.com/k2-fsa/sherpa-onnx and https://pub.dev/packages/sherpa_onnx
- Piper voices: https://github.com/rhasspy/piper/blob/master/VOICES.md, successor https://github.com/OHF-Voice/piper1-gpl
- Kokoro-82M: https://huggingface.co/hexgrad/Kokoro-82M (not reachable from this box; languages and voice counts from search results)
- Supertonic: https://github.com/supertone-inc/supertonic
- sherpa-onnx TTS engine APKs: https://k2-fsa.github.io/sherpa/onnx/tts/apk-engine.html
