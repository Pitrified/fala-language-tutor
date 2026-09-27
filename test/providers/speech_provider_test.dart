import 'package:fala/models/target_language.dart';
import 'package:fala/providers/speech_provider.dart';
import 'package:fala/services/speech/fake_speech_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeSpeechService speech;
  late ProviderContainer container;

  setUp(() {
    speech = FakeSpeechService();
    container = ProviderContainer(
      overrides: [speechServiceProvider.overrideWithValue(speech)],
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
}
