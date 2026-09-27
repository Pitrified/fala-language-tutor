import 'package:fala/models/target_language.dart';
import 'package:fala/screens/settings/widgets/language_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('languageSwitchAction', () {
    test('a dismissed sheet does nothing', () {
      expect(
        languageSwitchAction(
          picked: null,
          current: TargetLanguage.ptBr,
          hasMessages: true,
        ),
        LanguageSwitchAction.none,
      );
    });

    test('picking the language already in use does nothing', () {
      expect(
        languageSwitchAction(
          picked: TargetLanguage.ptBr,
          current: TargetLanguage.ptBr,
          hasMessages: false,
        ),
        LanguageSwitchAction.none,
      );
    });

    test('an empty conversation switches in place', () {
      expect(
        languageSwitchAction(
          picked: TargetLanguage.esEs,
          current: TargetLanguage.ptBr,
          hasMessages: false,
        ),
        LanguageSwitchAction.switchInPlace,
      );
    });

    test('a conversation with messages asks before restarting', () {
      expect(
        languageSwitchAction(
          picked: TargetLanguage.esEs,
          current: TargetLanguage.ptBr,
          hasMessages: true,
        ),
        LanguageSwitchAction.confirmRestart,
      );
    });
  });

  testWidgets('the confirm dialog names the language and both choices', (
    tester,
  ) async {
    bool? answer;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              answer = await showLanguageSwitchDialog(
                context,
                language: TargetLanguage.frFr,
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Start over in French?'), findsOneWidget);
    expect(find.text('Keep this one'), findsOneWidget);

    await tester.tap(find.text('Keep this one'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(answer, isFalse);
  });
}
