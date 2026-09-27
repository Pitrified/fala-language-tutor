import 'package:fala/models/tutor_response.dart';
import 'package:fala/screens/conversation/widgets/correction_card.dart';
import 'package:fala/screens/conversation/widgets/streaming_reply_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrapWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('displays corrections with original and corrected text', (
    tester,
  ) async {
    const corrections = [
      CorrectionError(
        original: 'eu sou',
        corrected: 'eu estou',
        explanation: 'Use estar for temporary states',
      ),
    ];

    await tester.pumpWidget(
      wrapWidget(const CorrectionCard(corrections: corrections)),
    );

    // RichText contains the correction spans
    expect(find.byType(RichText), findsWidgets);
    expect(find.text('Use estar for temporary states'), findsOneWidget);
  });

  testWidgets('displays multiple corrections', (tester) async {
    const corrections = [
      CorrectionError(original: 'a', corrected: 'b', explanation: 'fix 1'),
      CorrectionError(original: 'c', corrected: 'd', explanation: 'fix 2'),
    ];

    await tester.pumpWidget(
      wrapWidget(const CorrectionCard(corrections: corrections)),
    );

    expect(find.text('fix 1'), findsOneWidget);
    expect(find.text('fix 2'), findsOneWidget);
  });

  // A long original that has arrived before its correction used to sit in a
  // Row, which gives text unbounded width: it ran off the card instead of
  // wrapping, until the corrected text arrived and a RichText took over.
  const longOriginal =
      'ontem eu tinha ido ao mercado com a minha irmã e nós compramos '
      'muitas frutas e legumes para a semana inteira';

  for (final (label, partial) in [
    ('original only', const PartialCorrection(original: longOriginal)),
    (
      'original and corrected',
      const PartialCorrection(original: longOriginal, corrected: 'fui'),
    ),
  ]) {
    testWidgets('a long streaming correction wraps ($label)', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          const Center(
            child: SizedBox(
              width: 240,
              child: CorrectionCard.partial(partials: []),
            ),
          ),
        ),
      );
      await tester.pumpWidget(
        wrapWidget(
          Center(
            child: SizedBox(
              width: 240,
              child: CorrectionCard.partial(partials: [partial]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final original = find.textContaining(
        'ontem eu tinha ido',
        findRichText: true,
      );
      expect(original, findsOneWidget);
      expect(tester.getSize(original).width, lessThanOrEqualTo(240));
      expect(tester.getSize(original).height, greaterThan(30));
    });
  }
}
