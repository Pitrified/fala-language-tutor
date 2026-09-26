import 'dart:async';

import '../inference/inference_engine.dart';

/// Top-level application state.
sealed class AppState {
  const AppState();
}

/// The selected engine is being initialized.
class AppLoading extends AppState {
  const AppLoading();
}

/// The engine is initialized and a conversation can start.
class AppReady extends AppState {
  const AppReady();
}

/// Initialization failed; [message] says why.
class AppError extends AppState {
  const AppError({required this.message});
  final String message;
}

/// Controls application-level lifecycle.
///
/// Initializes the selected inference engine and exposes state for the
/// welcome screen and the router to decide what the user can do.
class AppController {
  AppController({required this.engineFactory, required this.onEngineReady});

  /// Builds the engine for the currently selected engine kind.
  final InferenceEngine Function() engineFactory;

  /// Called once the engine is initialized, to publish it to the app.
  final void Function(InferenceEngine engine) onEngineReady;

  InferenceEngine? _engine;

  AppState _state = const AppLoading();
  final _stateController = StreamController<AppState>.broadcast();

  /// Current application state.
  AppState get state => _state;

  /// Stream of state changes for reactive UI.
  Stream<AppState> get stateStream => _stateController.stream;

  /// Run the initialization sequence.
  ///
  /// Builds and initializes the engine. Times out after 10 seconds if engine
  /// init hangs.
  Future<void> initialize() async {
    _setState(const AppLoading());

    _engine = engineFactory();

    try {
      await _engine!.initialize().timeout(const Duration(seconds: 10));
    } on TimeoutException {
      _setState(const AppError(message: 'Engine initialization timed out'));
      return;
    }

    if (_engine!.isReady) {
      onEngineReady(_engine!);
      _setState(const AppReady());
    } else {
      _setState(
        const AppError(message: 'Failed to initialize inference engine'),
      );
    }
  }

  void _setState(AppState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  /// Dispose resources.
  Future<void> dispose() async {
    await _stateController.close();
  }
}
