/// Identifies which inference engine implementation is active.
///
/// Persisted in [AppSettingsRepository] under the `engine_kind` key as the
/// enum's [name]. Selection in the Settings screen drives which factory the
/// engine registry returns.
enum EngineKind {
  /// Scripted responses from an asset fixture. Used in tests and for UI
  /// smoke testing without a key.
  fake,

  /// OpenAI cloud chat completions.
  openai,
}

/// UI helpers for [EngineKind].
extension EngineKindX on EngineKind {
  /// Human-readable label shown in the Settings selector.
  String get displayName {
    switch (this) {
      case EngineKind.fake:
        return 'Fake (scripted)';
      case EngineKind.openai:
        return 'OpenAI (cloud)';
    }
  }

  /// Whether a factory is registered for this kind in the engine registry.
  ///
  /// Returns `false` only for kinds that are reserved but not yet wired up.
  bool get isImplemented {
    switch (this) {
      case EngineKind.fake:
      case EngineKind.openai:
        return true;
    }
  }

  /// Whether this kind needs an API key in `ApiKeyStore` before it can answer.
  bool get requiresKey {
    switch (this) {
      case EngineKind.fake:
        return false;
      case EngineKind.openai:
        return true;
    }
  }
}
