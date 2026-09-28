import 'package:fala/models/target_language.dart';
import 'package:fala/providers/speech_provider.dart';
import 'package:fala/screens/conversation/widgets/speak_button.dart';
import 'package:fala/services/speech/fake_speech_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/speech_overrides.dart';

void main() {
  Future<void> pumpButton(WidgetTester tester, FakeSpeechService speech) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          speechServiceProvider.overrideWithValue(speech),
          ...speechChoiceOverrides,
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SpeakButton(
              messageId: 'm1',
              text: 'Hola, ¿qué tal?',
              language: TargetLanguage.esEs,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('plays the reply in its language, then stops on a second tap', (
    tester,
  ) async {
    final speech = FakeSpeechService();
    await pumpButton(tester, speech);

    await tester.tap(find.byTooltip('Read aloud'));
    await tester.pump();
    expect(speech.spoken.single, ('Hola, ¿qué tal?', TargetLanguage.esEs));
    expect(find.byTooltip('Stop reading'), findsOneWidget);

    await tester.tap(find.byTooltip('Stop reading'));
    await tester.pump();
    expect(speech.isSpeaking, isFalse);
    expect(find.byTooltip('Read aloud'), findsOneWidget);
  });

  testWidgets('the icon returns when the reply finishes by itself', (
    tester,
  ) async {
    final speech = FakeSpeechService();
    await pumpButton(tester, speech);

    await tester.tap(find.byTooltip('Read aloud'));
    await tester.pump();
    speech.finishCurrent();
    await tester.pump();
    expect(find.byTooltip('Read aloud'), findsOneWidget);
  });

  testWidgets('without a voice, explains and offers the install screen', (
    tester,
  ) async {
    final speech = FakeSpeechService(voices: {TargetLanguage.ptBr});
    await pumpButton(tester, speech);

    await tester.tap(find.byTooltip('Read aloud'));
    await tester.pumpAndSettle();
    expect(find.text('No Spanish voice'), findsOneWidget);
    expect(speech.spoken, isEmpty);

    await tester.tap(find.text('Install voice'));
    await tester.pumpAndSettle();
    expect(speech.installRequests, 1);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
