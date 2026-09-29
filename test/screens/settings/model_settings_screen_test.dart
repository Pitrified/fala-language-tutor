import 'dart:io';

import 'package:fala/build_info.dart';
import 'package:fala/providers/settings_provider.dart';
import 'package:fala/screens/settings/model_settings_screen.dart';
import 'package:fala/services/inference/openai_models.dart';
import 'package:fala/services/settings/app_settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late AppSettingsRepository settings;
  var run = 0;

  setUp(() async {
    run++;
    FlutterSecureStorage.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('model_screen_');
    Hive.init(tempDir.path);
    settings = AppSettingsRepository(boxName: 'model_screen_$run');
    await settings.initialize();
  });

  // The box is not closed: a close after a write made from the widget test
  // hangs, and each test opens its own box in its own folder.
  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  /// Lets Hive and the key store answer; pumpAndSettle alone would wait
  /// on them forever under the test's fake clock.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appSettingsRepositoryProvider.overrideWithValue(settings)],
        child: const MaterialApp(home: ModelSettingsScreen()),
      ),
    );
    await settle(tester);
  }

  final nano = openAiModelOptions[0];
  final luna = openAiModelOptions[1];

  testWidgets('shows the default model and its description', (tester) async {
    await pump(tester);
    expect(find.text(nano.id), findsOneWidget);
    expect(find.text(nano.description), findsOneWidget);
  });

  testWidgets('choosing a model saves it and shows its description', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text(nano.id));
    await settle(tester);
    // The handler writes to Hive: dispatch it in real time so the write
    // completes instead of waiting on the fake clock.
    await tester.runAsync(() async {
      await tester.tap(find.text(luna.id).last);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await settle(tester);

    expect(settings.openaiModel(), luna.id);
    expect(find.text(luna.description), findsOneWidget);
  });

  testWidgets('links the guide to getting a key', (tester) async {
    await pump(tester);
    expect(find.text('How to get an OpenAI key'), findsOneWidget);
  });

  test('the key guide link points at a file in this repository', () {
    const prefix = '$sourceRepoUrl/blob/main/';
    expect(openAiKeyGuideUrl, startsWith(prefix));
    expect(
      File(openAiKeyGuideUrl.substring(prefix.length)).existsSync(),
      isTrue,
    );
  });

  testWidgets('a stored model that is not offered stays listed', (
    tester,
  ) async {
    await tester.runAsync(() => settings.setOpenaiModel('gpt-4o-mini'));
    await pump(tester);
    expect(find.text('gpt-4o-mini'), findsOneWidget);
  });
}
