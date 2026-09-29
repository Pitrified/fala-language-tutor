import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../models/target_language.dart';
import '../../providers/app_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/app/app_controller.dart';
import '../onboarding/onboarding_screen.dart';

/// Welcome screen - app entry point.
///
/// Displays the app name, a loading indicator, and the start button. On a new
/// install it reads "Get started" and opens the first-run setup; after that,
/// "Setup model" and the Model page while the selected engine still needs a
/// key, else "Start learning".
/// Triggers app initialization on first build.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _triggerInit();
  }

  Future<void> _triggerInit() async {
    if (_initialized) return;
    _initialized = true;
    final appController = ref.read(appControllerProvider);
    await appController.initialize();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appController = ref.watch(appControllerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: StreamBuilder<AppState>(
              stream: appController.stateStream,
              initialData: appController.state,
              builder: (context, snapshot) {
                final state = snapshot.data ?? const AppLoading();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'fala',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Learn ${ref.watch(defaultTargetLanguageProvider).displayName} '
                      'by speaking',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 48),
                    _buildStatusWidget(context, state),
                    const SizedBox(height: 32),
                    if (state is AppReady &&
                        ref.watch(onboardingNeededProvider) == true)
                      FilledButton(
                        onPressed: () => context.push(
                          OnboardingScreen.routeFor(OnboardingStep.model),
                        ),
                        child: const Text('Get started'),
                      )
                    else if (state is AppReady)
                      switch (ref.watch(modelSetupNeededProvider)) {
                        // The key store has not answered yet.
                        null => const SizedBox.shrink(),
                        true => FilledButton(
                          onPressed: () =>
                              context.push(AppRoutes.modelSettings),
                          child: const Text('Setup model'),
                        ),
                        false => FilledButton(
                          onPressed: () => context.go(AppRoutes.conversation),
                          child: const Text('Start learning'),
                        ),
                      },
                    if (state is AppLoading) const CircularProgressIndicator(),
                    if (state is AppError)
                      Column(
                        children: [
                          Text(
                            state.message,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () => appController.initialize(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusWidget(BuildContext context, AppState state) {
    return switch (state) {
      AppLoading() => const Text('Loading...'),
      AppReady() || AppError() => const SizedBox.shrink(),
    };
  }
}
