import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../providers/settings_provider.dart';
import '../settings/language_settings_screen.dart';
import '../settings/model_settings_screen.dart';

/// The first-run setup pages, in order.
enum OnboardingStep { model, language, reply }

/// One page of the first-run setup: the model, then language and level, then
/// reply length, "say it better" and speech. The settings are the same
/// widgets as on the settings pages and save as they change.
///
/// The model page's Next waits for the model to be ready; "Set it later"
/// skips it. The other pages start from the defaults, so Next is always on.
/// The last page's Start records the setup as done and opens the
/// conversation, or the welcome screen while the model still needs setup.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key, required this.step});

  /// Which page this is.
  final OnboardingStep step;

  static String routeFor(OnboardingStep step) =>
      '${AppRoutes.onboarding}/${step.name}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = step.index;
    final last = index == OnboardingStep.values.length - 1;
    final (title, body) = switch (step) {
      OnboardingStep.model => ('Model', const ModelSettingsBody()),
      OnboardingStep.language => (
        'Language and level',
        const LanguageLevelSettings(),
      ),
      OnboardingStep.reply => ('Replies and speech', const ReplySettings()),
    };
    final modelReady = ref.watch(modelSetupNeededProvider) == false;
    final canGoOn = step != OnboardingStep.model || modelReady;

    Future<void> next() async {
      if (!last) {
        await context.push(routeFor(OnboardingStep.values[index + 1]));
        return;
      }
      await ref.read(onboardingDoneProvider.notifier).finish();
      if (!context.mounted) return;
      context.go(modelReady ? AppRoutes.conversation : AppRoutes.welcome);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${index + 1} of ${OnboardingStep.values.length}'),
            ),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [body]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              if (step == OnboardingStep.model)
                TextButton(
                  onPressed: () =>
                      context.push(routeFor(OnboardingStep.values[index + 1])),
                  child: const Text('Set it later'),
                ),
              const Spacer(),
              FilledButton(
                onPressed: canGoOn ? next : null,
                child: Text(last ? 'Start' : 'Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
