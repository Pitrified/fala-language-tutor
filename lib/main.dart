import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'providers/diagnostics_provider.dart';
import 'providers/service_providers.dart';
import 'providers/settings_provider.dart';
import 'services/diagnostics/diagnostics_log.dart';
import 'services/inference/engine_kind.dart';
import 'services/persistence/conversation_repository.dart';
import 'services/settings/app_settings_repository.dart';

/// Set to true via --dart-define=FAKE_ENGINE=true for dev/test builds.
///
/// Forces the fake engine on this run instead of the persisted choice (the
/// default is OpenAI), and persists it so the Settings screen reflects it.
const bool kUseFakeEngine = bool.fromEnvironment(
  'FAKE_ENGINE',
  defaultValue: false,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final settings = AppSettingsRepository();
  await settings.initialize();

  // Developer override: --dart-define=FAKE_ENGINE=true forces the fake engine
  // on this run and persists the choice so the Settings screen reflects it.
  if (kUseFakeEngine) {
    await settings.setEngineKind(EngineKind.fake);
  }

  final repo = ConversationRepository();
  await repo.initialize();

  final diagnostics = await DiagnosticsLog.open();

  runApp(
    ProviderScope(
      overrides: [
        appSettingsRepositoryProvider.overrideWithValue(settings),
        conversationRepositoryProvider.overrideWithValue(repo),
        diagnosticsLogProvider.overrideWithValue(diagnostics),
      ],
      child: const FalaApp(),
    ),
  );
}
