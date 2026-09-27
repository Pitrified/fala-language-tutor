---
status: done
---

# 01 - Speaker button on tutor replies

## Overview

`00_start.md` D1, D2, D3, D5 and the dialog half of D6: the speech service, and a speaker icon on each tutor reply that plays it or stops it.

## Change

- `pubspec.yaml`: `flutter_tts`. `AndroidManifest.xml`: the `TTS_SERVICE` query. `MainActivity.kt`: the `fala/speech` channel with `openVoiceInstall`.
- `lib/services/speech/`: `SpeechService`, `speakableText`, `SystemSpeechService`, `FakeSpeechService`.
- `lib/providers/speech_provider.dart`: `speechServiceProvider` and `speechProvider`, which holds the id of the message being read.
- `MessageBubble` takes an optional `trailing` widget; the conversation list passes a `SpeakButton` for tutor messages.
- The stop triggers of D5 in `ConversationScreen` and `SettingsEntries`.

## Tests

- `speakableText` drops emoji and markdown symbols and keeps accented letters.
- `speechProvider`: one message at a time, the state clears when speech ends, a stale end does not clear a newer message.
- `SpeakButton`: plays the reply in the conversation's language, shows stop while playing, stops on a second tap; with no voice, the dialog and its "Install voice" button.
- The conversation screen stops speech on send.

## Done when

- The tests pass and `scripts/check.sh` passes.
- On the Pixel, a reply is read in the conversation's language, the icon stops it, and leaving the app stops it. Checked by the user on 2026-09-27.
