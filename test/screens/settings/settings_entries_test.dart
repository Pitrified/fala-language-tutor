import 'dart:async';

import 'package:fala/app.dart';
import 'package:fala/screens/settings/settings_entries.dart';
import 'package:fala/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// A router with the real settings paths. The two pages are stand-ins: this
  /// checks where the entries lead, not what the pages hold.
  GoRouter router() => GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          key: scaffoldKey,
          appBar: AppBar(),
          drawer: const Drawer(child: SettingsEntries()),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'language',
            builder: (context, state) =>
                const Scaffold(body: Text('language page')),
          ),
          GoRoute(
            path: 'model',
            builder: (context, state) =>
                const Scaffold(body: Text('model page')),
          ),
        ],
      ),
    ],
  );

  Future<GoRouter> pumpApp(WidgetTester tester) async {
    final r = router();
    await tester.pumpWidget(MaterialApp.router(routerConfig: r));
    return r;
  }

  for (final (entry, page) in [
    ('Language', 'language page'),
    ('Model', 'model page'),
  ]) {
    testWidgets(
      'the drawer entry $entry opens its page and closes the drawer',
      (tester) async {
        final r = await pumpApp(tester);
        scaffoldKey.currentState!.openDrawer();
        await tester.pumpAndSettle();

        await tester.tap(find.text(entry));
        await tester.pumpAndSettle();
        expect(find.text(page), findsOneWidget);

        r.pop();
        await tester.pumpAndSettle();
        expect(scaffoldKey.currentState!.isDrawerOpen, isFalse);
      },
    );
  }

  testWidgets('the Settings index lists the same entries', (tester) async {
    final r = await pumpApp(tester);
    unawaited(r.push(AppRoutes.settings));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.text('Model'));
    await tester.pumpAndSettle();
    expect(find.text('model page'), findsOneWidget);
  });
}
