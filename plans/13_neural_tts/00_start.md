---
status: planned
priority: 0
description: |
  Replace or supplement the phone's text-to-speech voice with a neural voice model that fala
  ships and runs on the device: which models, how they reach the phone, how they plug in.
---

# On-device neural voices

Spun off on 2026-09-28 from [`../12_system_tts/00_start.md`](../12_system_tts/00_start.md), after the system voice turned out robotic on the Pixel.
[`../05_audio_io/00_start.md`](../05_audio_io/00_start.md) stays the home of speech input and of the cloud and self-hosted voices.

Status: research. Nothing implemented, no phases derived.

Update 2026-09-28: Q1 to Q6 answered; the decisions and phase 01 are at the end.

## Where this came from

"We want a new spin off folder with research on a custom on device tts model. The current one default is very robotic. What are the options? How to integrate it?" (user, 2026-09-28)

## What the code gives us today

- Speech sits behind `SpeechService` (`isVoiceAvailable`, `speak`, `stop`, `openVoiceInstall`), with `SystemSpeechService` over `flutter_tts` and `FakeSpeechService` for tests. A second implementation slots in without touching the screens.
- `speakableText()` already strips emoji and markdown before anything is spoken.
- The five target languages are `pt-BR`, `es-ES`, `fr-FR`, `it-IT`, `de-DE`. Any model has to be judged on all five, and on `pt-BR` first. (Narrowed by Q1: `pt-BR` and `es-ES` are the two that matter.)
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

## Google's stack (LiteRT)

Added on 2026-09-28 after "Litert or the other Google things for a custom model. How to integrate them in flutter?" (user).

What Google offers for speech output on the device, read from the upstream pages that day:

- **No text-to-speech in the higher-level Google tools.** MediaPipe has no text-to-speech task. Gemma 3n and Gemma 4 take audio in and give text out, with no speech output. LiteRT-LM, which `flutter_gemma` wraps, runs language models only.
- **LiteRT itself** (formerly TensorFlow Lite) runs any converted model, with GPU and NPU acceleration through its CompiledModel API. That is the Google path for a custom voice.
- **Google's `litert-samples`** has two Android (Kotlin) text-to-speech samples:
  - Matcha-TTS with a HiFi-GAN vocoder. It is English only, with one LJSpeech voice. Its phonemizer is a dictionary plus a small neural model, with no espeak-ng. Upstream reports a real-time factor of about 0.8 on a Pixel 8a. The code is MIT, and the phonemizer is BSD and MIT.
  - KittenTTS nano, 15M parameters and 32 MB, which streams sentence by sentence. Its languages are not stated; KittenTTS is English as far as its upstream says.
- **`litert-community/Kokoro-82M`** is a LiteRT conversion of Kokoro. Its pipeline pairs it with an English-only neural phonemizer (DeepPhonemizer `en_us`). The model card reports a real-time factor of about 1.8 on a Pixel 8a (fp32, CPU, 4 threads), which is slower than real time, and names quantization as the way to real time. The Kokoro voices exist for pt-BR, es, fr and it, but the LiteRT pipeline has no phonemizer for them. Adding one means either espeak-ng (GPL-3.0, the same Q3) or a Portuguese neural phonemizer that has not been looked for yet.
- **Converting a model ourselves.** Google's PyTorch-to-LiteRT converter (AI Edge Torch) could in principle convert Piper's VITS models or others. That is model engineering (dynamic shapes, unsupported ops, checking the output by ear), not integration.

So LiteRT today gives an accelerated runtime and English samples. For our five languages it leaves the same gap as sherpa-onnx, namely the phonemizer, and it runs fewer ready models.

Flutter integration, if LiteRT were chosen:

- **L1. `flutter_litert` in Dart.** A community package (Apache-2.0, verified publisher, forked from the unmaintained `tflite_flutter`, 3.9.2 at the time of writing) that bundles the LiteRT runtime and exposes both the interpreter and the CompiledModel API, including the GPU delegate. The phonemizer, tokenizer, sentence split and audio assembly would all be written in Dart, and inference runs in a background isolate.
- **L2. Kotlin, next to `MainActivity`.** Add Google's LiteRT Maven artifact to the Android build and port the Kotlin pipeline from `litert-samples` almost as is. The Dart side stays a thin `NeuralSpeechService` over the existing `fala/speech` method channel: speak, stop, a "done" event. Audio plays through `AudioTrack` in Kotlin with our own audio focus handling, as in P2. Google's samples are Kotlin, so this reuses the most code, and Android is the only platform fala targets.

Either one is a new dependency and needs approval. L2 reuses Google's code; L1 keeps the logic in Dart, where the tests are.

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
  ANS: pt-BR, for the owner, and es-ES, for a friend. The other three are placeholders: nice to have, not judged for now (user, 2026-09-28).
- Q2: Is a one-time model download per language (D2) acceptable, or must a voice work offline from install (D1)?
  ANS: D2, downloaded on demand per language. The template repo has patterns for it from its local LLM experiment (user, 2026-09-28).
- Q3: fala has no licence file. Is linking GPL-3.0 espeak-ng acceptable (M1, M2), or does that rule them out and leave M3?
  ANS: "while license is a future issue, this app will not be commercially sold. it's for personal use, me and a friend, that's it." (user, 2026-09-28). Not a blocker for now; what GPL-3.0 would mean is under "GPL-3.0 in practice" below.
- Q4: Does the neural voice replace the system one where available (S1), or is it a per-language choice (S2)?
  ANS: replace it (S1) (user, 2026-09-28).
- Q5: Run the no-code listening test on the Pixel first, before any dependency or phase?
  ANS: yes, with a phase just for it (user, 2026-09-28). Answered together with "both options are interesting, google and sherpa" (O0a and O0b), and "if needed we can re-open the 12 system feature folder with a new phase (or two) for these experiments".
- Q6: Runtime: sherpa-onnx (R1), or LiteRT through Kotlin (L2) or `flutter_litert` (L1)? LiteRT gives GPU acceleration and Google's samples; sherpa-onnx runs more ready multilingual models today.
  ANS: R1, sherpa-onnx. "as long as it's real-time we do not care about GPU. it's a mean to an end" (user, 2026-09-28). LiteRT comes back only if no sherpa-onnx model reaches real time on the Pixel.

Also asked on 2026-09-28, outside the questions:

- On the integration: "neat options, good code, simple rather than uselessly convoluted".
- On measuring: logs that are easy to get from a release APK on the Pixel. adb only sometimes; better a dump on a debug page in the app that can be copied and pasted back, with metadata filled in automatically so nobody has to describe what was done.

## GPL-3.0 in practice

Written for Q3. It is not legal advice, and it only matters if M1 or M2 wins.

- The obligations start when a program is conveyed, meaning a copy is given to someone else. Using a build yourself triggers nothing. Handing the APK to a friend, or through a Play test track, is conveying.
- When conveying, the whole program that links the GPL code has to be offered under GPL-3.0 terms: the recipient gets the complete source, may change and redistribute it, and no extra restrictions may be added.
- fala's source is already public on GitHub. Complying would mean adding a GPL-3.0 licence file to the repo, keeping the notices of the bundled libraries in the app, and pointing recipients at the source, which the drawer's "Source: fala" link already does.
- Apache-2.0 and MIT dependencies (sherpa-onnx, Riverpod and the rest) can be combined into a GPL-3.0 program.
- It would stop the code from being relicensed as closed source without first removing espeak-ng. Given the answer to Q3, that is a cost on paper only.

## Decisions

- D1: pt-BR and es-ES are the languages a neural voice is chosen for. The code stays per language, so another language is a model entry, not a feature.
- D2: the listening test runs inside fala rather than through Android settings. Choosing the TTS engine and voice in the app, and the diagnostics page for measurements, are system speech features, so they go into `12_system_tts` as its phases 03 and 04. The test decides this folder, so it is this folder's phase 01, and waits on those two.
- D3: if the test picks a neural model, the runtime is `sherpa_onnx` (R1). Its dependency approval is asked for then, not now.
- D4: models arrive by download on demand per language (D2 in "How the model reaches the phone"), with a SHA-256 check. The starting point is the template's pattern in flutter-setup-project: `lib/services/model/model_manager.dart` streams a sealed `DownloadStatus` to the UI, keeps files under the app's documents directory and deletes the partial file on failure, and `lib/screens/model_download/model_download_screen.dart` has the progress bar and retry. The template's checksum check is still a TODO, and its real LLM download went through `flutter_gemma`'s own installer, so that manager was never run against a real file.
- D5: a downloaded neural voice replaces the system voice for its language (S1). The system voice stays for every language without a model.
- D6: what is still open (M1, M2 or M3; P1 or P2; how model archives are unpacked) waits for the result of phase 01. The later phases are derived then.

## Sources

- LiteRT samples: https://github.com/google-ai-edge/litert-samples
- LiteRT Kokoro: https://huggingface.co/litert-community/Kokoro-82M (model card read through search results)
- flutter_litert: https://pub.dev/packages/flutter_litert
- Gemma audio: https://ai.google.dev/gemma/docs/capabilities/audio
- sherpa-onnx: https://github.com/k2-fsa/sherpa-onnx and https://pub.dev/packages/sherpa_onnx
- Piper voices: https://github.com/rhasspy/piper/blob/master/VOICES.md, successor https://github.com/OHF-Voice/piper1-gpl
- Kokoro-82M: https://huggingface.co/hexgrad/Kokoro-82M (not reachable from this box; languages and voice counts from search results)
- Supertonic: https://github.com/supertone-inc/supertonic
- sherpa-onnx TTS engine APKs: https://k2-fsa.github.io/sherpa/onnx/tts/apk-engine.html
