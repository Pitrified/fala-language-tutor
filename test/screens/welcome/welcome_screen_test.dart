import 'dart:io';

import 'package:fala/providers/app_provider.dart';
import 'package:fala/providers/settings_provider.dart';
import 'package:fala/screens/welcome/welcome_screen.dart';
import 'package:fala/services/app/app_controller.dart';
import 'package:fala/services/inference/fake_inference_engine.dart';
import 'package:fala/services/settings/app_settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late AppSettingsRepository settings;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_welcome_test_');
    Hive.init(tempDir.path);
    settings = AppSettingsRepository(boxName: 'test_welcome_settings');
    await settings.initialize();
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  testWidgets('once ready, offers "Start learning" and no model line', (
    tester,
  ) async {
    final app = AppController(
      engineFactory: () => FakeInferenceEngine(responseDelayMs: 0),
      onEngineReady: (_) {},
    );
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appControllerProvider.overrideWithValue(app),
            appSettingsRepositoryProvider.overrideWithValue(settings),
          ],
          child: const MaterialApp(home: WelcomeScreen()),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();

    expect(app.state, isA<AppReady>());
    expect(find.text('Start learning'), findsOneWidget);
    expect(find.textContaining('Model:'), findsNothing);
  });
}
