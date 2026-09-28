import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/target_language.dart';
import '../services/speech/speech_service.dart';
import '../services/speech/system_speech_service.dart';
import 'diagnostics_provider.dart';
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
  /// [trigger] says what started it, `button` or `auto`, for the diagnostics
  /// line each utterance writes.
  Future<void> play({
    required String messageId,
    required String text,
    required TargetLanguage language,
    String trigger = 'button',
  }) async {
    final generation = ++_generation;
    state = messageId;
    final engine = ref.read(speechEngineProvider);
    final voice = ref.read(speechVoiceProvider)[language];
    final spoken = speakableText(text);
    final log = ref.read(diagnosticsLogProvider);
    final clock = Stopwatch()..start();
    Duration? started;
    final outcome = await ref
        .read(speechServiceProvider)
        .speak(
          spoken,
          language,
          engine: engine,
          voice: voice,
          onStart: () => started = clock.elapsed,
        );
    final start = started;
    unawaited(
      log.add(
        [
          'speak',
          trigger,
          language.code,
          'engine=${engine ?? 'default'}',
          'voice=${voice ?? 'default'}',
          'chars=${spoken.length}',
          'start_ms=${start?.inMilliseconds ?? '-'}',
          'speak_ms=${start == null ? '-' : (clock.elapsed - start).inMilliseconds}',
          outcome,
        ].join(' '),
      ),
    );
    if (ref.mounted && generation == _generation) state = null;
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
    unawaited(
      ref.read(diagnosticsLogProvider).add('engine ${engine ?? 'default'}'),
    );
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
    unawaited(
      ref
          .read(diagnosticsLogProvider)
          .add('voice ${language.code} ${voice ?? 'default'}'),
    );
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

/// The current engine's local voices for a language. Network voices are left
/// out: the local ones sound as good on the Pixel, and keep the text on the
/// phone.
final speechVoicesProvider =
    FutureProvider.family<List<SpeechVoice>, TargetLanguage>((
      ref,
      language,
    ) async {
      final voices = await ref
          .watch(speechServiceProvider)
          .voices(language, engine: ref.watch(speechEngineProvider));
      return [
        for (final voice in voices)
          if (!voice.online) voice,
      ];
    });
