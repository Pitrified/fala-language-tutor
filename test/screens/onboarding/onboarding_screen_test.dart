import 'dart:io';

import 'package:fala/app.dart';
import 'package:fala/providers/conversation_provider.dart';
import 'package:fala/providers/settings_provider.dart';
import 'package:fala/providers/speech_provider.dart';
import 'package:fala/screens/onboarding/onboarding_screen.dart';
import 'package:fala/services/settings/api_key_store.dart';
import 'package:fala/services/settings/app_settings_repository.dart';
import 'package:fala/services/speech/fake_speech_service.dart';
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
    tempDir = await Directory.systemTemp.createTemp('onboarding_');
    Hive.init(tempDir.path);
    settings = AppSettingsRepository(boxName: 'onboarding_$run');
    await settings.initialize();
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  /// Hive and the key store need real time; the widget clock is fake.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// A tap whose handler writes to Hive, dispatched in real time.
  Future<void> tapReal(WidgetTester tester, Finder finder) async {
    await tester.runAsync(() async {
      await tester.tap(finder);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await settle(tester);
  }

  Future<void> pumpFlow(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: OnboardingScreen.routeFor(OnboardingStep.model),
      routes: [
        GoRoute(
          path: AppRoutes.welcome,
          builder: (context, state) => const Text('welcome page'),
        ),
        GoRoute(
          path: AppRoutes.conversation,
          builder: (context, state) => const Text('conversation page'),
        ),
        for (final step in OnboardingStep.values)
          GoRoute(
            path: OnboardingScreen.routeFor(step),
            builder: (context, state) => OnboardingScreen(step: step),
          ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsRepositoryProvider.overrideWithValue(settings),
          speechServiceProvider.overrideWithValue(FakeSpeechService()),
          conversationControllerProvider.overrideWithValue(null),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await settle(tester);
  }

  FilledButton button(WidgetTester tester, String label) => tester.widget(
    find.ancestor(of: find.text(label), matching: find.byType(FilledButton)),
  );

  testWidgets('without a key the model page has no way on', (tester) async {
    await pumpFlow(tester);
    expect(find.text('1 of 3'), findsOneWidget);
    expect(button(tester, 'Next').onPressed, isNull);
    expect(find.text('Set it later'), findsNothing);
  });

  testWidgets(
    'with a key stored, Next is on and Start opens the conversation',
    (tester) async {
      await tester.runAsync(() => ApiKeyStore().write('sk-test'));
      await pumpFlow(tester);
      expect(button(tester, 'Next').onPressed, isNotNull);

      await tapReal(tester, find.text('Next').last);
      expect(find.text('Language and level'), findsOneWidget);
      expect(find.text('CEFR level'), findsOneWidget);
      expect(find.text('Reply length'), findsNothing);

      await tapReal(tester, find.text('Next').last);
      expect(find.text('Replies and speech'), findsOneWidget);
      expect(find.text('Reply length'), findsOneWidget);
      expect(find.text('Say it better with every reply'), findsOneWidget);
      expect(find.text('Speech'), findsOneWidget);

      await tapReal(tester, find.text('Start').last);
      expect(settings.onboardingDone(), isTrue);
      expect(find.text('conversation page'), findsOneWidget);
    },
  );

  test(
    'a new install needs the setup, a finished or keyed one does not',
    () async {
      final container = ProviderContainer(
        overrides: [appSettingsRepositoryProvider.overrideWithValue(settings)],
      );
      addTearDown(container.dispose);
      container.listen(onboardingNeededProvider, (_, _) {});
      await container.read(apiKeyPresentProvider.future);
      expect(container.read(onboardingNeededProvider), isTrue);

      await container.read(onboardingDoneProvider.notifier).finish();
      expect(container.read(onboardingNeededProvider), isFalse);
      expect(settings.onboardingDone(), isTrue);
    },
  );
}
