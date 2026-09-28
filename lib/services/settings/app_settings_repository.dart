import 'dart:convert';

import 'package:hive/hive.dart';

import '../../models/cefr_level.dart';
import '../../models/target_language.dart';
import '../inference/engine_kind.dart';

/// Hive-backed store for non-secret app settings.
///
/// Uses a single `Box<String>` (`app_settings` by default), with plain string
/// values keyed by the constants on this class. Enums are persisted via
/// [Enum.name] and parsed defensively so a renamed value does not crash the
/// app - the documented default is used instead.
///
/// Secrets (the OpenAI API key) live in `ApiKeyStore`, not here.
class AppSettingsRepository {
  AppSettingsRepository({this.boxName = boxNameDefault});

  /// Default Hive box name. Exposed for tests that want a fresh box.
  static const String boxNameDefault = 'app_settings';

  /// Hive key storing the selected [EngineKind] as its [Enum.name].
  static const String keyEngineKind = 'engine_kind';

  /// Hive key storing the OpenAI model id (used by 03.2). Reserved here.
  static const String keyOpenaiModel = 'openai_model';

  /// Hive key storing the default [CefrLevel] for new conversations.
  static const String keyDefaultCefr = 'default_cefr';

  /// Hive key storing the default topic seed for new conversations.
  static const String keyDefaultTopic = 'default_topic';

  /// Hive key storing the recent custom topics as a JSON array, newest first.
  static const String keyRecentTopics = 'recent_topics';

  /// Hive key storing the default [TargetLanguage] as its BCP-47 code.
  static const String keyDefaultLanguage = 'default_language';

  /// Hive key storing whether replies are read aloud, as `'true'` or
  /// `'false'`.
  static const String keyReadRepliesAloud = 'read_replies_aloud';

  /// Key for the text-to-speech engine's package name; unset is the phone's
  /// default engine.
  static const String keySpeechEngine = 'speech_engine';

  /// Prefix of the per-language voice keys, e.g. `speech_voice_pt-BR`; unset
  /// is the engine's default voice.
  static const String keySpeechVoicePrefix = 'speech_voice_';

  /// Fallback when no value is stored or the stored value is unknown.
  static const EngineKind defaultEngineKind = EngineKind.openai;

  /// Fallback OpenAI model id used by 03.2.
  static const String defaultOpenaiModel = 'gpt-4o-mini';

  /// Fallback CEFR level for the very first conversation.
  static const CefrLevel defaultCefrLevel = CefrLevel.a1;

  /// Empty string means "no topic" (the prompt template degrades gracefully).
  static const String defaultTopic = '';

  /// Fallback target language, which is what every conversation stored before
  /// the language became a setting already carries.
  static const TargetLanguage defaultTargetLanguage = TargetLanguage.ptBr;

  final String boxName;
  late Box<String> _box;

  /// Open the Hive box. Must be called before any other method.
  Future<void> initialize() async {
    _box = await Hive.openBox<String>(boxName);
  }

  /// Returns the persisted [EngineKind], or [defaultEngineKind] when none is
  /// stored or the stored value does not map to a known enum case.
  EngineKind engineKind() {
    final raw = _box.get(keyEngineKind);
    if (raw == null) return defaultEngineKind;
    try {
      return EngineKind.values.byName(raw);
    } on ArgumentError {
      return defaultEngineKind;
    }
  }

  /// Persist [kind] as the active engine selection.
  Future<void> setEngineKind(EngineKind kind) async {
    await _box.put(keyEngineKind, kind.name);
  }

  /// Returns the persisted OpenAI model id, or [defaultOpenaiModel].
  String openaiModel() {
    return _box.get(keyOpenaiModel) ?? defaultOpenaiModel;
  }

  /// Persist [model] as the OpenAI model id.
  Future<void> setOpenaiModel(String model) async {
    await _box.put(keyOpenaiModel, model);
  }

  /// Returns the persisted default [CefrLevel], or [defaultCefrLevel] when
  /// none is stored or the stored value does not map to a known level.
  CefrLevel defaultCefr() {
    return CefrLevelX.fromString(_box.get(keyDefaultCefr)) ?? defaultCefrLevel;
  }

  /// Persist [level] as the default CEFR level for new conversations.
  Future<void> setDefaultCefr(CefrLevel level) async {
    await _box.put(keyDefaultCefr, level.name);
  }

  /// Returns the persisted default topic seed (or empty string).
  String defaultTopicValue() {
    return _box.get(keyDefaultTopic) ?? defaultTopic;
  }

  /// Whether each new reply is read aloud. Off unless set to `'true'`, so a
  /// fresh install stays silent.
  bool readRepliesAloud() => _box.get(keyReadRepliesAloud) == 'true';

  /// Persist whether new replies are read aloud.
  Future<void> setReadRepliesAloud(bool value) async {
    await _box.put(keyReadRepliesAloud, value.toString());
  }

  /// The chosen text-to-speech engine, or null for the phone's default.
  String? speechEngine() => _box.get(keySpeechEngine);

  /// Persist the text-to-speech engine; null returns to the phone's default.
  Future<void> setSpeechEngine(String? engine) =>
      _putOrDelete(keySpeechEngine, engine);

  /// The chosen voice for [language], or null for the engine's default.
  String? speechVoice(TargetLanguage language) =>
      _box.get('$keySpeechVoicePrefix${language.code}');

  /// Persist the voice for [language]; null returns to the engine's default.
  Future<void> setSpeechVoice(TargetLanguage language, String? voice) =>
      _putOrDelete('$keySpeechVoicePrefix${language.code}', voice);

  Future<void> _putOrDelete(String key, String? value) =>
      value == null ? _box.delete(key) : _box.put(key, value);

  /// Persist [topic] as the default topic seed for new conversations.
  Future<void> setDefaultTopic(String topic) async {
    await _box.put(keyDefaultTopic, topic);
  }

  /// Returns the recent custom topics, newest first, or an empty list when
  /// none are stored or the stored value is not a JSON array of strings.
  List<String> recentTopics() {
    final raw = _box.get(keyRecentTopics);
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List && decoded.every((e) => e is String)) {
        return decoded.cast<String>();
      }
    } on FormatException {
      // Fall through to the empty list.
    }
    return const [];
  }

  /// Persist [topics] as the recent custom topics, newest first.
  Future<void> setRecentTopics(List<String> topics) async {
    await _box.put(keyRecentTopics, jsonEncode(topics));
  }

  /// Returns the persisted default [TargetLanguage], or
  /// [defaultTargetLanguage] when none is stored or the stored code is not one
  /// of the supported languages.
  TargetLanguage defaultLanguage() {
    return TargetLanguageX.fromCode(_box.get(keyDefaultLanguage)) ??
        defaultTargetLanguage;
  }

  /// Persist [language] as the default for new conversations.
  Future<void> setDefaultLanguage(TargetLanguage language) async {
    await _box.put(keyDefaultLanguage, language.code);
  }

  /// Close the underlying Hive box.
  Future<void> close() async {
    await _box.close();
  }
}
