import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/target_language.dart';
import '../services/speech/speech_service.dart';
import '../services/speech/system_speech_service.dart';
import 'settings_provider.dart';

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
    await ref
        .read(speechServiceProvider)
        .speak(
          speakableText(text),
          language,
          engine: ref.read(speechEngineProvider),
          voice: ref.read(speechVoiceProvider)[language],
        );
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
  (ref, language) => ref
      .watch(speechServiceProvider)
      .isVoiceAvailable(language, engine: ref.watch(speechEngineProvider)),
);

/// The chosen text-to-speech engine's package name, or null for the phone's
/// default.
class SpeechEngineNotifier extends Notifier<String?> {
  @override
  String? build() => ref.read(appSettingsRepositoryProvider).speechEngine();

  /// Persist [engine] and publish it.
  Future<void> set(String? engine) async {
    if (engine == state) return;
    await ref.read(appSettingsRepositoryProvider).setSpeechEngine(engine);
    state = engine;
  }
}

/// Provider for [SpeechEngineNotifier].
final speechEngineProvider = NotifierProvider<SpeechEngineNotifier, String?>(
  SpeechEngineNotifier.new,
);

/// The chosen voice per language; a language that is absent uses the engine's
/// default voice.
class SpeechVoiceNotifier extends Notifier<Map<TargetLanguage, String>> {
  @override
  Map<TargetLanguage, String> build() {
    final settings = ref.read(appSettingsRepositoryProvider);
    return {
      for (final language in TargetLanguage.values)
        language: ?settings.speechVoice(language),
    };
  }

  /// Persist [voice] for [language] and publish it; null is the default.
  Future<void> set(TargetLanguage language, String? voice) async {
    if (voice == state[language]) return;
    await ref
        .read(appSettingsRepositoryProvider)
        .setSpeechVoice(language, voice);
    final next = {...state};
    if (voice == null) {
      next.remove(language);
    } else {
      next[language] = voice;
    }
    state = next;
  }
}

/// Provider for [SpeechVoiceNotifier].
final speechVoiceProvider =
    NotifierProvider<SpeechVoiceNotifier, Map<TargetLanguage, String>>(
      SpeechVoiceNotifier.new,
    );

/// Installed text-to-speech engines, by package name.
final speechEnginesProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(speechServiceProvider).engines(),
);

/// The current engine's voices for a language.
final speechVoicesProvider =
    FutureProvider.family<List<SpeechVoice>, TargetLanguage>(
      (ref, language) => ref
          .watch(speechServiceProvider)
          .voices(language, engine: ref.watch(speechEngineProvider)),
    );
