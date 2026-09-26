# AppController

> System spec for `lib/services/app/app_controller.dart`

## Purpose

Controls top-level application lifecycle: builds and initializes the selected inference
engine, and exposes reactive state for the welcome screen and the router (loading, ready to
start a conversation, or an error with a retry).

## State machine

```
AppLoading -> AppReady        (engine initialized)
AppLoading -> AppError        (init timeout or failure)
AppError   -> AppLoading      (initialize() called again, e.g. from Retry)
```

`AppState` is a sealed class with three subtypes:

| State | Meaning |
|-------|---------|
| `AppLoading` | Initialization in progress |
| `AppReady` | Engine initialized |
| `AppError` | Something failed (message field) |

## Constructor parameters

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `engineFactory` | `InferenceEngine Function()` | yes | Builds the engine for the selected engine kind |
| `onEngineReady` | `void Function(InferenceEngine)` | yes | Callback fired when the engine reaches ready state |

## Public API

| Method | Signature | Description |
|--------|-----------|-------------|
| `state` | `AppState get state` | Current state (synchronous read) |
| `stateStream` | `Stream<AppState> get stateStream` | Broadcast stream of state changes |
| `initialize()` | `Future<void>` | Create the engine, initialize it, call onEngineReady |
| `dispose()` | `Future<void>` | Close stream controller |

## Behavior details

- `initialize()` times out engine init after 10 seconds.
- `onEngineReady` is only called when `engine.isReady == true` after initialization.
- The router keeps the conversation route unreachable until the state is `AppReady`.

## Dependencies

- `InferenceEngine` (interface)

## Provider

`appControllerProvider` in `lib/providers/app_provider.dart`, rebuilt when the selected
engine kind changes because it watches `engineFactoryProvider`:

```dart
final appControllerProvider = Provider<AppController>((ref) {
  final factory = ref.watch(engineFactoryProvider);
  return AppController(
    engineFactory: factory,
    onEngineReady: (engine) {
      ref.read(inferenceEngineProvider.notifier).setEngine(engine);
    },
  );
});
```
