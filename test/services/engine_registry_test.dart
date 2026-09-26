import 'dart:io';

import 'package:fala/services/inference/engine_kind.dart';
import 'package:fala/services/inference/engine_registry.dart';
import 'package:fala/services/inference/fake_inference_engine.dart';
import 'package:fala/services/inference/openai_inference_engine.dart';
import 'package:fala/services/settings/api_key_store.dart';
import 'package:fala/services/settings/app_settings_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late AppSettingsRepository settings;
  late EngineRegistryDeps deps;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('hive_registry_test_');
    Hive.init(tempDir.path);
    settings = AppSettingsRepository(boxName: 'reg_test_settings');
    await settings.initialize();
    deps = EngineRegistryDeps(apiKeyStore: ApiKeyStore(), settings: settings);
  });

  tearDown(() async {
    await settings.close();
    await tempDir.delete(recursive: true);
  });

  group('engineFactoryFor', () {
    test('returns a FakeInferenceEngine factory for EngineKind.fake', () {
      final factory = engineFactoryFor(EngineKind.fake, deps);
      expect(factory(), isA<FakeInferenceEngine>());
    });

    test('returns an OpenAiInferenceEngine factory for EngineKind.openai', () {
      final factory = engineFactoryFor(EngineKind.openai, deps);
      expect(factory(), isA<OpenAiInferenceEngine>());
    });
  });

  group('EngineKindX', () {
    test('every kind is implemented', () {
      for (final kind in EngineKind.values) {
        expect(kind.isImplemented, isTrue, reason: kind.name);
      }
    });

    test('displayName is non-empty for every value', () {
      for (final kind in EngineKind.values) {
        expect(kind.displayName, isNotEmpty);
      }
    });
  });
}
