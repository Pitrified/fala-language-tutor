import 'package:fala/models/topic.dart';
import 'package:fala/screens/conversation/widgets/topic_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<String> removed;
  Topic? picked;

  Future<void> openSheet(
    WidgetTester tester, {
    List<String> recent = const [],
  }) async {
    removed = [];
    picked = null;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              picked = await showTopicPickerSheet(
                context,
                current: Topic.none,
                recent: recent,
                onRemoveRecent: (topic) async => removed.add(topic),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('no recent topics shows no recent section', (tester) async {
    await openSheet(tester);
    expect(find.text('Recent'), findsNothing);
    expect(find.text(kSuggestedTopics.first.value), findsOneWidget);
  });

  testWidgets('recent topics are listed newest first and can be picked', (
    tester,
  ) async {
    await openSheet(tester, recent: ['ciclismo', 'jazz']);
    expect(find.text('Recent'), findsOneWidget);
    final ciclismo = tester.getTopLeft(find.text('ciclismo'));
    final jazz = tester.getTopLeft(find.text('jazz'));
    expect(ciclismo.dy, lessThan(jazz.dy));

    await tester.tap(find.text('jazz'));
    await tester.pumpAndSettle();
    expect(picked, const Topic(value: 'jazz'));
    expect(picked!.isCustom, isTrue);
  });

  testWidgets('removing a recent topic keeps the sheet open', (tester) async {
    await openSheet(tester, recent: ['ciclismo', 'jazz']);
    await tester.tap(find.byTooltip('Remove ciclismo'));
    await tester.pumpAndSettle();
    expect(removed, ['ciclismo']);
    expect(find.text('ciclismo'), findsNothing);
    expect(find.text('jazz'), findsOneWidget);
    expect(picked, isNull);

    await tester.tap(find.byTooltip('Remove jazz'));
    await tester.pumpAndSettle();
    expect(find.text('Recent'), findsNothing);
  });
}
