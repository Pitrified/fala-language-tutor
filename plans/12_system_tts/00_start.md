---
status: done
priority: 0
description: |
  Read the tutor's replies aloud with Android's system text-to-speech: what is spoken, when it
  starts, and every way it stops.
---

# System text-to-speech

Spun off on 2026-09-27 from option O1 of [`../05_audio_io/00_start.md`](../05_audio_io/00_start.md), which stays the home of speech input and of the cloud and self-hosted voices.

Options below, as first written; the answers to Q1 to Q7 and the decisions they lead to are at the end.

## Where this came from

"Ok spin off a folder for system tts. Suggest options for how we would integrate it, what would be spoken, how, when, how to stop it if changing app or sending new message or if the user gets bored." (user, 2026-09-27)

## What the code gives us today

- A tutor turn is a `TutorResponse`: `correction` (`content` is the corrected sentence, `translation` its English, `errors` each with an English `explanation`) and `conversation` (`content` is the reply in the target language, `translation` its English). The correction is empty when the learner made no mistake.
- The reply streams: the bubble shows the reply prefix as it arrives, then the committed message replaces it.
- Every conversation carries its `TargetLanguage`, whose `code` is a BCP-47 tag (`pt-BR`, `es-ES`, `fr-FR`, `it-IT`, `de-DE`). That is the locale a TTS engine takes.
- `ConversationScreen` is already a `WidgetsBindingObserver`, so app lifecycle changes reach it.
- Everything in the reply is text the app already has: speaking it sends nothing new off the device.

## How to integrate

- **I1. `flutter_tts` plugin.** The common wrapper over Android `TextToSpeech`: speak, stop, pause, rate, pitch, locale and voice lists, completion and progress callbacks. A new dependency, so it needs approval.
- **I2. Our own platform channel** to `android.speech.tts.TextToSpeech` in Kotlin. No dependency; we write and maintain the init, utterance callbacks and audio focus handling ourselves.

Either way it sits behind a `SpeechService` interface in `lib/services/speech/`, with a `FakeSpeechService` that records what it was asked to say, so widget tests never touch the platform (the same rule as `FakeInferenceEngine`). A provider exposes it and a small notifier holds "what is speaking now" for the UI.

Voice availability is per device. Before offering speech for a language we ask the engine whether the locale is available. If not:

- **A1.** Hide the speaker control for that language.
- **A2.** Show it, and on tap explain the voice is missing with a button to Android's "install voice data" screen.

## What is spoken

- **S1. The reply only** (`conversation.content`). The one thing in the target language that is always there. Simplest.
- **S2. The corrected sentence, then the reply.** Hearing the right version of what you just said is useful practice; skipped when there is no correction.
- **S3. S2 plus the English translations**, in an English voice. Doubles the length and mixes languages; more a comprehension aid than practice.

The English explanations of errors are not candidates: they are for reading.

Before speaking, strip what reads badly aloud: emoji, markdown symbols, and brackets the model sometimes adds.

## How it sounds

- **Locale** from the conversation's language, not the default, so a resumed Spanish conversation is read in Spanish after the default moved to French.
- **Rate.** R1: one speed, the engine's default. R2: a speed setting (slow / normal). R3: slower by default at A1 and A2, normal from B1, which ties speed to the level the learner already chose.
- **Voice.** Engine default for the locale at first; a voice picker only if the default is poor on the Pixel.
- **Audio focus.** Take transient focus with ducking so music lowers rather than stops; stop when another app takes focus (a call, a voice note).

## When it speaks

- **W1. On demand.** A speaker icon on each tutor bubble; tap to play, tap again to stop. Old messages can be replayed.
- **W2. Automatically, once the reply is complete.** A "Read replies aloud" setting; the committed reply is spoken. Nothing starts before the whole JSON has arrived.
- **W3. Automatically, sentence by sentence while streaming.** The first sentence starts while the rest is still arriving. Lowest wait, but sentence splitting on a partial prefix, and a correction block that streams first, make it the hardest to get right.

W1 is useful on its own, and W2 adds one setting and one trigger on top of it. Auto-play never fires for messages loaded from history: resuming a conversation stays silent.

## How it stops

Only one utterance plays at a time: starting one stops the other.

| Trigger | Proposed behaviour |
| --- | --- |
| The learner sends a new message | Stop at once. |
| The learner starts typing | Option: stop too, since typing means they have moved on. Or keep reading so they can answer while listening. |
| The app goes to the background (home, app switch, screen off) | Stop on `paused`; do not resume when the app comes back. |
| Another app takes audio focus (a call, a voice message) | Stop. |
| The learner leaves the conversation (drawer page, Settings, new conversation, the resume choice) | Stop. |
| "Bored" | Tap the speaker icon of the playing bubble, which shows a stop icon while it plays. Option: also a small "Stop" chip above the input bar while anything plays, so there is no need to find the bubble. |

Pausing and resuming mid-sentence is left out: Android's engine stops and restarts rather than pausing, and a reply is a few sentences.

## Settings

A "Speech" section on the Language page, since voices are per language: the auto-play switch (with W2), the speed (with R2), and a line when the current language has no voice installed.

## Open questions

- Q1: `flutter_tts` (new dependency) or our own platform channel?
  ANS: `flutter_tts`; the new dependency is approved (user, 2026-09-27).
- Q2: What is spoken: the reply only (S1), or the corrected sentence first (S2)?
  ANS: the reply only (user, 2026-09-27).
- Q3: When: on demand only (W1), or also automatic after a complete reply (W2)? Is sentence-by-sentence streaming (W3) worth its complexity, now or later?
  ANS: both W1 and W2: W1 to replay a specific message, W2 to hear each reply automatically (user, 2026-09-27). W3 not asked for.
- Q4: Speed: engine default (R1), a setting (R2), or tied to the CEFR level (R3)?
  ANS: the engine default at all levels (user, 2026-09-27).
- Q5: Does typing in the input bar stop the speech?
  ANS: no (user, 2026-09-27).
- Q6: Is a separate "Stop" chip wanted, or is the bubble's own icon enough?
  ANS: no chip, the bubble's icon only (user, 2026-09-27).
- Q7: A missing voice: hide the control (A1) or explain and link to the install screen (A2)?
  ANS: explain and link: "a user starting a new language might not have the full phone set up for that yet" (user, 2026-09-27).

## Decisions

- D1: `flutter_tts` behind a `SpeechService` interface in `lib/services/speech/`, with `SystemSpeechService` for the app and `FakeSpeechService` for tests. The install-voice link is not in `flutter_tts`, so a small method channel in `MainActivity` fires Android's install-voice-data intent, falling back to the text-to-speech settings screen. The manifest declares the `TTS_SERVICE` query, which `flutter_tts` needs on Android 11 and later.
- D2: spoken text is `conversation.content`, with emoji and markdown symbols removed; the locale is the conversation's language; the rate is the engine's.
- D3: a speaker icon beside every tutor bubble plays that reply and turns into a stop icon while it plays. Starting one reply stops any other.
- D4: "Read replies aloud" is a switch in a "Speech" section of the Language page, off by default for now, so a fresh install does not start talking in a public place. With it on, a reply is read once it is complete and committed, only while the conversation is on screen and the app in the foreground. Replies loaded from history are never read by themselves.
- D5: speech stops when the learner sends a message, starts a new conversation, resumes one, opens a settings page, or leaves the app (`paused` or `hidden`, not `inactive`, so pulling down the notification shade does not cut it). Typing does not stop it (Q5). A call moves the app to the background, which covers that case; `flutter_tts` requests ducking focus but ignores losing it, so another app starting to play sound while fala is in the foreground does not stop fala. That is left as is until it proves to matter.
- D6: with no voice for the conversation's language, tapping the speaker opens a dialog that says so and offers "Install voice". Automatic reading skips silently; the Speech section says when the current language has no voice, with the same "Install voice" button, and checks again when the app comes back to the foreground.
