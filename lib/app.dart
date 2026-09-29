import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/app_provider.dart';
import 'screens/conversation/conversation_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/settings/diagnostics_screen.dart';
import 'screens/settings/language_settings_screen.dart';
import 'screens/settings/model_settings_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/welcome/welcome_screen.dart';
import 'services/app/app_controller.dart';

/// Route path constants.
abstract final class AppRoutes {
  static const welcome = '/';
  static const conversation = '/conversation';
  static const settings = '/settings';
  static const languageSettings = '/settings/language';
  static const modelSettings = '/settings/model';
  static const diagnostics = '/settings/diagnostics';
  static const onboarding = '/onboarding';
  static const history = '/conversations';
}

/// App-level GoRouter configuration.
///
/// Uses manual Provider (not @riverpod) because GoRouter setup is declarative
/// configuration, not async/stateful logic. This is a common Flutter pattern.
final routerProvider = Provider<GoRouter>((ref) {
  final appController = ref.watch(appControllerProvider);

  return GoRouter(
    initialLocation: AppRoutes.welcome,
    redirect: (context, state) {
      final appState = appController.state;
      final location = state.matchedLocation;

      // Settings, its pages and the first-run setup are always reachable.
      if (location.startsWith(AppRoutes.settings) ||
          location.startsWith(AppRoutes.onboarding)) {
        return null;
      }

      // Prevent accessing conversation if not ready
      if (location == AppRoutes.conversation && appState is! AppReady) {
        return AppRoutes.welcome;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      for (final step in OnboardingStep.values)
        GoRoute(
          path: OnboardingScreen.routeFor(step),
          builder: (context, state) => OnboardingScreen(step: step),
        ),
      GoRoute(
        path: AppRoutes.conversation,
        builder: (context, state) => const ConversationScreen(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'language',
            builder: (context, state) => const LanguageSettingsScreen(),
          ),
          GoRoute(
            path: 'model',
            builder: (context, state) => const ModelSettingsScreen(),
          ),
          GoRoute(
            path: 'diagnostics',
            builder: (context, state) => const DiagnosticsScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Root application widget.
class FalaApp extends ConsumerWidget {
  const FalaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'fala',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
