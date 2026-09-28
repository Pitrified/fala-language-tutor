import 'package:fala/models/target_language.dart';
import 'package:fala/providers/speech_provider.dart';

/// Engine and voice choices held in memory, for tests that play speech
/// without a settings repository.
final speechChoiceOverrides = [
  speechEngineProvider.overrideWith(_MemoryEngine.new),
  speechVoiceProvider.overrideWith(_MemoryVoices.new),
];

class _MemoryEngine extends SpeechEngineNotifier {
  @override
  String? build() => null;

  @override
  Future<void> set(String? engine) async => state = engine;
}

class _MemoryVoices extends SpeechVoiceNotifier {
  @override
  Map<TargetLanguage, String> build() => const {};

  @override
  Future<void> set(TargetLanguage language, String? voice) async {
    state = {...state, language: ?voice};
  }
}
