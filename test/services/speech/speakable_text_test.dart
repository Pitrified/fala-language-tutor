import 'package:fala/services/speech/speech_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('drops emoji and markdown symbols, keeps accented letters', () {
    expect(
      speakableText('**Olá!** Você gosta de café? ☕😊'),
      'Olá! Você gosta de café?',
    );
  });

  test('collapses whitespace left behind', () {
    expect(
      speakableText('Ça  va?\n\n_Très_ bien 👍 merci'),
      'Ça va? Très bien merci',
    );
  });

  test('leaves plain text as it is', () {
    expect(speakableText('Wie geht es dir?'), 'Wie geht es dir?');
  });
}
