import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../models/target_language.dart';
import '../logging/app_logger.dart';
import 'speech_service.dart';

/// [SpeechService] over Android's `TextToSpeech`, through `flutter_tts`.
///
/// `flutter_tts` reports the end of an utterance through handlers that carry
/// no utterance id, and stopping one utterance to start the next reports a
/// cancel that can arrive after the next one was requested. So an end event
/// only counts once the current utterance has reported its start; a cancel
/// before that belongs to the previous one.
class SystemSpeechService implements SpeechService {
  SystemSpeechService({FlutterTts? tts}) : _tts = tts ?? FlutterTts() {
    _tts.setStartHandler(() => _started = true);
    _tts.setCompletionHandler(_finishIfStarted);
    _tts.setCancelHandler(_finishIfStarted);
    _tts.setErrorHandler((message) {
      AppLogger.instance.warn('Text-to-speech error: $message');
      _finish();
    });
  }

  /// Channel to `MainActivity` for what `flutter_tts` does not cover.
  static const _channel = MethodChannel('fala/speech');

  final FlutterTts _tts;
  Completer<void>? _current;
  bool _started = false;

  void _finishIfStarted() {
    if (_started) _finish();
  }

  void _finish() {
    final current = _current;
    _current = null;
    _started = false;
    if (current != null && !current.isCompleted) current.complete();
  }

  @override
  Future<bool> isVoiceAvailable(TargetLanguage language) async {
    try {
      return await _tts.isLanguageInstalled(language.code) == true;
    } on PlatformException catch (e) {
      AppLogger.instance.warn('Voice check failed for ${language.code}: $e');
      return false;
    }
  }

  @override
  Future<void> speak(String text, TargetLanguage language) async {
    await stop();
    final current = Completer<void>();
    _current = current;
    await _tts.setLanguage(language.code);
    // Transient focus that lets music duck rather than stop.
    final result = await _tts.speak(text, focus: true);
    if (result != 1) _finish();
    return current.future;
  }

  @override
  Future<void> stop() async {
    _finish();
    await _tts.stop();
  }

  @override
  Future<bool> openVoiceInstall() async {
    try {
      return await _channel.invokeMethod<bool>('openVoiceInstall') ?? false;
    } on PlatformException catch (e) {
      AppLogger.instance.warn('Could not open voice install: $e');
      return false;
    }
  }
}
