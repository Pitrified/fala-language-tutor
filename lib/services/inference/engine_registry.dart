import '../settings/api_key_store.dart';
import '../settings/app_settings_repository.dart';
import 'engine_kind.dart';
import 'fake_inference_engine.dart';
import 'inference_engine.dart';
import 'openai_inference_engine.dart';
import 'tutor_response_schema.dart';

/// Factory that creates an [InferenceEngine].
typedef EngineFactory = InferenceEngine Function();

/// Dependencies the registry hands to engine factories that need them.
///
/// `fake` ignores everything in here; `openai` uses the API key store and
/// reads its model id from the settings repo on every call.
class EngineRegistryDeps {
  const EngineRegistryDeps({required this.apiKeyStore, required this.settings});

  final ApiKeyStore apiKeyStore;
  final AppSettingsRepository settings;
}

/// Returns the [EngineFactory] registered for [kind].
///
/// Adding a new engine is a single entry in this switch plus a new
/// [EngineKind] value.
EngineFactory engineFactoryFor(EngineKind kind, EngineRegistryDeps deps) {
  switch (kind) {
    case EngineKind.fake:
      return FakeInferenceEngine.new;
    case EngineKind.openai:
      return () => OpenAiInferenceEngine(
        apiKeyStore: deps.apiKeyStore,
        modelProvider: deps.settings.openaiModel,
        schemaName: 'tutor_response',
        schema: tutorResponseJsonSchema,
      );
  }
}
