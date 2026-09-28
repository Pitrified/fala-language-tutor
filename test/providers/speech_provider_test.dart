import 'package:fala/models/target_language.dart';
import 'package:fala/providers/diagnostics_provider.dart';
import 'package:fala/providers/speech_provider.dart';
import 'package:fala/services/diagnostics/diagnostics_log.dart';
import 'package:fala/services/speech/fake_speech_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/speech_overrides.dart';

void main() {
  late FakeSpeechService speech;
  late ProviderContainer container;
  late DiagnosticsLog log;

  setUp(() {
    speech = FakeSpeechService();
    log = DiagnosticsLog();
    container = ProviderContainer(
      overrides: [
        speechServiceProvider.overrideWithValue(speech),
        ...speechChoiceOverrides,
        diagnosticsLogProvider.overrideWithValue(log),
      ],
    );
  });

  tearDown(() => container.dispose());

  SpeechNotifier notifier() => container.read(speechProvider.notifier);
  String? playing() => container.read(speechProvider);

  test(
    'plays cleaned text in the given language and clears at the end',
    () async {
      final done = notifier().play(
        messageId: 'm1',
        text: 'Hola 😊',
        language: TargetLanguage.esEs,
      );
      expect(playing(), 'm1');
      expect(speech.spoken.single, ('Hola', TargetLanguage.esEs));

      speech.finishCurrent();
      await done;
      expect(playing(), isNull);
    },
  );

  test('a newer message is not cleared when the older one ends', () async {
    final first = notifier().play(
      messageId: 'm1',
      text: 'Um',
      language: TargetLanguage.ptBr,
    );
    final second = notifier().play(
      messageId: 'm2',
      text: 'Dois',
      language: TargetLanguage.ptBr,
    );
    await first;
    expect(playing(), 'm2');

    speech.finishCurrent();
    await second;
    expect(playing(), isNull);
  });

  test('stop clears the state and stops the service', () async {
    final done = notifier().play(
      messageId: 'm1',
      text: 'Um',
      language: TargetLanguage.ptBr,
    );
    await notifier().stop();
    await done;
    expect(playing(), isNull);
    expect(speech.isSpeaking, isFalse);
    expect(speech.stopCount, 1);
  });

  test('each utterance logs one line, without its text', () async {
    final done = notifier().play(
      messageId: 'm1',
      text: 'Olá mundo',
      language: TargetLanguage.ptBr,
      trigger: 'auto',
    );
    speech.startCurrent();
    speech.finishCurrent();
    await done;
    await Future<void>.delayed(Duration.zero);

    final line = log.lines.single;
    expect(line, contains('speak auto pt-BR engine=default voice=default'));
    expect(line, contains('chars=9'));
    expect(line, matches(RegExp(r'start_ms=\d+ speak_ms=\d+ finished$')));
    expect(line, isNot(contains('mundo')));
  });

  test('a stopped or failed utterance says so', () async {
    final first = notifier().play(
      messageId: 'm1',
      text: 'Oi',
      language: TargetLanguage.ptBr,
    );
    await notifier().stop();
    await first;
    final second = notifier().play(
      messageId: 'm2',
      text: 'Oi',
      language: TargetLanguage.ptBr,
    );
    speech.failCurrent('no voice');
    await second;
    await Future<void>.delayed(Duration.zero);

    expect(log.lines[0], endsWith('start_ms=- speak_ms=- stopped'));
    expect(log.lines[1], endsWith('error no voice'));
  });
}
