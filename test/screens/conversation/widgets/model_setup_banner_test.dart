import 'package:fala/app.dart';
import 'package:fala/screens/conversation/widgets/model_setup_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('the banner names the problem and opens the Model page', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: ModelSetupBanner()),
        ),
        GoRoute(
          path: AppRoutes.modelSettings,
          builder: (context, state) => const Scaffold(body: Text('model page')),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.byIcon(Icons.priority_high), findsOneWidget);
    await tester.tap(find.text('Model setup needed'));
    await tester.pumpAndSettle();
    expect(find.text('model page'), findsOneWidget);
  });
}
