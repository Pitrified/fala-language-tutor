import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/target_language.dart';
import '../services/speech/speech_service.dart';
import '../services/speech/system_speech_service.dart';

/// The text-to-speech service. Tests override it with `FakeSpeechService`.
final speechServiceProvider = Provider<SpeechService>(
  (ref) => SystemSpeechService(),
);

/// Which message is being read aloud: its id, or null when nothing plays.
///
/// Every start and stop goes through here so the speaker icons agree on what
/// is playing, and so the screens that stop speech need not know which message
/// it was.
class SpeechNotifier extends Notifier<String?> {
  /// Bumped on every play and stop; a play whose speech ends after a newer
  /// play or stop leaves the state to that newer one.
  int _generation = 0;

  @override
  String? build() => null;

  /// Read [text] in [language] as message [messageId], stopping anything else.
  Future<void> play({
    required String messageId,
    required String text,
    required TargetLanguage language,
  }) async {
    final generation = ++_generation;
    state = messageId;
    await ref.read(speechServiceProvider).speak(speakableText(text), language);
    if (generation == _generation) state = null;
  }

  /// Stop whatever is playing.
  Future<void> stop() async {
    _generation++;
    state = null;
    await ref.read(speechServiceProvider).stop();
  }
}

/// Provider for [SpeechNotifier].
final speechProvider = NotifierProvider<SpeechNotifier, String?>(
  SpeechNotifier.new,
);

/// Whether a voice exists for a language. Invalidate it to check again, for
/// example when the app returns from the voice install screen.
final voiceAvailableProvider = FutureProvider.family<bool, TargetLanguage>(
  (ref, language) =>
      ref.watch(speechServiceProvider).isVoiceAvailable(language),
);
