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
    _tts.setStartHandler(() {
      _started = true;
      _onStart?.call();
    });
    _tts.setCompletionHandler(() => _finishIfStarted('finished'));
    _tts.setCancelHandler(() => _finishIfStarted('stopped'));
    _tts.setErrorHandler((message) {
      AppLogger.instance.warn('Text-to-speech error: $message');
      _finish('error $message');
    });
  }

  /// Channel to `MainActivity` for what `flutter_tts` does not cover.
  static const _channel = MethodChannel('fala/speech');

  final FlutterTts _tts;
  Completer<String>? _current;
  bool _started = false;
  void Function()? _onStart;

  /// The engine last set on the plugin; null while it is on the default.
  String? _engine;

  void _finishIfStarted(String outcome) {
    if (_started) _finish(outcome);
  }

  void _finish(String outcome) {
    final current = _current;
    _current = null;
    _started = false;
    _onStart = null;
    if (current != null && !current.isCompleted) current.complete(outcome);
  }

  /// Point the plugin at [engine], or back at the phone's default. An engine
  /// that is no longer installed falls back to the default.
  Future<void> _useEngine(String? engine) async {
    var target = engine;
    if (target != null && !(await engines()).contains(target)) {
      AppLogger.instance.warn('Speech engine $target is gone, using default');
      target = null;
    }
    if (target == _engine) return;
    try {
      final name = target ?? await _tts.getDefaultEngine as String?;
      if (name != null) await _tts.setEngine(name);
      _engine = target;
    } on PlatformException catch (e) {
      AppLogger.instance.warn('Could not switch speech engine to $target: $e');
    }
  }

  @override
  Future<List<String>> engines() async {
    try {
      final raw = await _tts.getEngines as List<dynamic>?;
      return [...?raw?.map((e) => e.toString())];
    } on PlatformException catch (e) {
      AppLogger.instance.warn('Could not list speech engines: $e');
      return const [];
    }
  }

  @override
  Future<List<SpeechVoice>> voices(
    TargetLanguage language, {
    String? engine,
  }) async {
    await _useEngine(engine);
    try {
      final raw = await _tts.getVoices as List<dynamic>?;
      final voices =
          [
              for (final entry in raw ?? const <dynamic>[])
                if (entry is Map)
                  SpeechVoice(
                    name: '${entry['name']}',
                    locale: '${entry['locale']}',
                    online: '${entry['network_required']}' == '1',
                  ),
            ].where((v) => voiceSpeaks(v.locale, language)).toList()
            ..sort((a, b) => a.name.compareTo(b.name));
      return voices;
    } on PlatformException catch (e) {
      AppLogger.instance.warn('Could not list voices for ${language.code}: $e');
      return const [];
    }
  }

  @override
  Future<bool> isVoiceAvailable(
    TargetLanguage language, {
    String? engine,
  }) async {
    await _useEngine(engine);
    try {
      return await _tts.isLanguageInstalled(language.code) == true;
    } on PlatformException catch (e) {
      AppLogger.instance.warn('Voice check failed for ${language.code}: $e');
      return false;
    }
  }

  @override
  Future<String> speak(
    String text,
    TargetLanguage language, {
    String? engine,
    String? voice,
    void Function()? onStart,
  }) async {
    await stop();
    final current = Completer<String>();
    _current = current;
    _onStart = onStart;
    await _useEngine(engine);
    if (!await _setVoice(language, voice)) {
      await _tts.setLanguage(language.code);
    }
    // Transient focus that lets music duck rather than stop.
    final result = await _tts.speak(text, focus: true);
    if (result != 1) _finish('error not started');
    return current.future;
  }

  /// Select [name] for [language]; false when there is none to select.
  Future<bool> _setVoice(TargetLanguage language, String? name) async {
    if (name == null) return false;
    final match = (await voices(
      language,
      engine: _engine,
    )).where((v) => v.name == name).firstOrNull;
    if (match != null &&
        await _tts.setVoice({'name': match.name, 'locale': match.locale}) ==
            1) {
      return true;
    }
    AppLogger.instance.warn('Voice $name is gone, using the default');
    return false;
  }

  @override
  Future<void> stop() async {
    _finish('stopped');
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
