import 'dart:io';

import 'package:fala/providers/settings_provider.dart';
import 'package:fala/services/inference/engine_kind.dart';
import 'package:fala/services/settings/app_settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late AppSettingsRepository settings;
  late ProviderContainer container;
  var run = 0;

  setUp(() async {
    run++;
    FlutterSecureStorage.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('model_setup_');
    Hive.init(tempDir.path);
    settings = AppSettingsRepository(boxName: 'model_setup_$run');
    await settings.initialize();
    container = ProviderContainer(
      overrides: [appSettingsRepositoryProvider.overrideWithValue(settings)],
    );
  });

  tearDown(() async {
    container.dispose();
    await tempDir.delete(recursive: true);
  });

  /// Read [modelSetupNeededProvider] once the key store has answered.
  Future<bool?> needed() async {
    container.listen(modelSetupNeededProvider, (_, _) {});
    await container.read(apiKeyPresentProvider.future);
    return container.read(modelSetupNeededProvider);
  }

  test('OpenAI without a key needs setup', () async {
    await settings.setEngineKind(EngineKind.openai);
    expect(await needed(), isTrue);
  });

  test('is unknown until the key store answers', () async {
    await settings.setEngineKind(EngineKind.openai);
    expect(container.read(modelSetupNeededProvider), isNull);
  });

  test('storing and clearing the key flips it after an invalidate', () async {
    await settings.setEngineKind(EngineKind.openai);
    expect(await needed(), isTrue);

    await container.read(apiKeyStoreProvider).write('sk-test');
    container.invalidate(apiKeyPresentProvider);
    expect(await needed(), isFalse);

    await container.read(apiKeyStoreProvider).clear();
    container.invalidate(apiKeyPresentProvider);
    expect(await needed(), isTrue);
  });

  test('the fake engine never needs setup', () async {
    await settings.setEngineKind(EngineKind.fake);
    expect(container.read(modelSetupNeededProvider), isFalse);
  });
}
