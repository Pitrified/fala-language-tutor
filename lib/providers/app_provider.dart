import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/app/app_controller.dart';
import 'inference_provider.dart';

/// Provider for the AppController.
///
/// Rebuilt when the selected engine kind changes, through
/// [engineFactoryProvider].
final appControllerProvider = Provider<AppController>((ref) {
  final factory = ref.watch(engineFactoryProvider);
  return AppController(
    engineFactory: factory,
    onEngineReady: (engine) {
      ref.read(inferenceEngineProvider.notifier).setEngine(engine);
    },
  );
});
