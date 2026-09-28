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

  Completer<String>? _current;
  void Function()? _onStart;

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
  Future<String> speak(
    String text,
    TargetLanguage language, {
    String? engine,
    String? voice,
    void Function()? onStart,
  }) {
    _end('stopped');
    spoken.add((text, language));
    spokenWith.add((engine, voice));
    final current = Completer<String>();
    _current = current;
    _onStart = onStart;
    return current.future;
  }

  @override
  Future<void> stop() async {
    stopCount++;
    _end('stopped');
  }

  /// Report that the current utterance's sound started.
  void startCurrent() => _onStart?.call();

  /// End the current utterance as if it had finished playing.
  void finishCurrent() => _end('finished');

  /// End the current utterance with an engine error.
  void failCurrent(String message) => _end('error $message');

  void _end(String outcome) {
    final current = _current;
    _current = null;
    _onStart = null;
    if (current != null && !current.isCompleted) current.complete(outcome);
  }

  @override
  Future<bool> openVoiceInstall() async {
    installRequests++;
    return true;
  }
}
