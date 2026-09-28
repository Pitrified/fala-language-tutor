import 'dart:async';

import '../../models/target_language.dart';
import 'speech_service.dart';

/// [SpeechService] for tests: records what it was asked to say and keeps each
/// utterance playing until [finishCurrent] or [stop].
class FakeSpeechService implements SpeechService {
  FakeSpeechService({
    Set<TargetLanguage>? voices,
    this.engineNames = const [],
    this.voiceList = const [],
  }) : languagesWithVoice = voices ?? TargetLanguage.values.toSet();

  /// What [engines] returns.
  final List<String> engineNames;

  /// Every voice of every engine; [voices] filters by language.
  final List<SpeechVoice> voiceList;

  /// The `(engine, voice)` of each [speak], in the order of [spoken].
  final List<(String?, String?)> spokenWith = [];

  /// Languages that have a voice. Tests remove one to simulate a missing voice.
  final Set<TargetLanguage> languagesWithVoice;

  /// Every `(text, language)` passed to [speak], in order.
  final List<(String, TargetLanguage)> spoken = [];

  /// How many times [stop] was called.
  int stopCount = 0;

  /// How many times [openVoiceInstall] was called.
  int installRequests = 0;

  Completer<void>? _current;

  /// Whether an utterance is playing.
  bool get isSpeaking => _current != null;

  @override
  Future<bool> isVoiceAvailable(
    TargetLanguage language, {
    String? engine,
  }) async => languagesWithVoice.contains(language);

  @override
  Future<List<String>> engines() async => engineNames;

  @override
  Future<List<SpeechVoice>> voices(
    TargetLanguage language, {
    String? engine,
  }) async => [
    for (final voice in voiceList)
      if (voiceSpeaks(voice.locale, language)) voice,
  ];

  @override
  Future<void> speak(
    String text,
    TargetLanguage language, {
    String? engine,
    String? voice,
  }) {
    _end();
    spoken.add((text, language));
    spokenWith.add((engine, voice));
    final current = Completer<void>();
    _current = current;
    return current.future;
  }

  @override
  Future<void> stop() async {
    stopCount++;
    _end();
  }

  /// End the current utterance as if it had finished playing.
  void finishCurrent() => _end();

  void _end() {
    final current = _current;
    _current = null;
    if (current != null && !current.isCompleted) current.complete();
  }

  @override
  Future<bool> openVoiceInstall() async {
    installRequests++;
    return true;
  }
}
