import 'dart:io';

import 'package:fala/app.dart';
import 'package:fala/providers/app_provider.dart';
import 'package:fala/providers/settings_provider.dart';
import 'package:fala/screens/onboarding/onboarding_screen.dart';
import 'package:fala/screens/welcome/welcome_screen.dart';
import 'package:fala/services/app/app_controller.dart';
import 'package:fala/services/inference/engine_kind.dart';
import 'package:fala/services/inference/fake_inference_engine.dart';
import 'package:fala/services/settings/app_settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late AppSettingsRepository settings;

  var run = 0;

  setUp(() async {
    run++;
    FlutterSecureStorage.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('hive_welcome_test_');
    Hive.init(tempDir.path);
    settings = AppSettingsRepository(boxName: 'test_welcome_settings_$run');
    await settings.initialize();
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  /// The welcome screen under a router with the real Model page path, the
  /// page itself a stand-in.
  Future<void> pumpWelcome(WidgetTester tester) async {
    final app = AppController(
      engineFactory: () => FakeInferenceEngine(responseDelayMs: 0),
      onEngineReady: (_) {},
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: AppRoutes.welcome,
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.modelSettings,
          builder: (context, state) => const Scaffold(body: Text('model page')),
        ),
        GoRoute(
          path: OnboardingScreen.routeFor(OnboardingStep.model),
          builder: (context, state) =>
              const Scaffold(body: Text('first setup page')),
        ),
      ],
    );
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appControllerProvider.overrideWithValue(app),
            appSettingsRepositoryProvider.overrideWithValue(settings),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    // The ready state is what first asks the key store, so give its answer a
    // frame of its own.
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    expect(app.state, isA<AppReady>());
  }

  testWidgets('once ready, offers "Start learning" and no model line', (
    tester,
  ) async {
    await tester.runAsync(() => settings.setEngineKind(EngineKind.fake));
    await pumpWelcome(tester);

    expect(find.text('Start learning'), findsOneWidget);
    expect(find.text('Setup model'), findsNothing);
    expect(find.textContaining('Model:'), findsNothing);
  });

  testWidgets('a new install offers "Get started", to the first setup page', (
    tester,
  ) async {
    await tester.runAsync(() => settings.setEngineKind(EngineKind.openai));
    await pumpWelcome(tester);

    expect(find.text('Setup model'), findsNothing);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('first setup page'), findsOneWidget);
  });

  testWidgets('OpenAI without a key offers "Setup model", to the Model page', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await settings.setEngineKind(EngineKind.openai);
      await settings.setOnboardingDone();
    });
    await pumpWelcome(tester);

    expect(find.text('Start learning'), findsNothing);
    await tester.tap(find.text('Setup model'));
    await tester.pumpAndSettle();
    expect(find.text('model page'), findsOneWidget);
  });

  testWidgets('OpenAI with a key offers "Start learning"', (tester) async {
    FlutterSecureStorage.setMockInitialValues({'openai_api_key': 'sk-test'});
    await tester.runAsync(() => settings.setEngineKind(EngineKind.openai));
    await pumpWelcome(tester);

    expect(find.text('Start learning'), findsOneWidget);
    expect(find.text('Setup model'), findsNothing);
  });
}
