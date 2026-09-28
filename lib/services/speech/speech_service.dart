import '../../models/target_language.dart';

/// One voice of a text-to-speech engine.
class SpeechVoice {
  const SpeechVoice({
    required this.name,
    required this.locale,
    this.online = false,
  });

  /// The engine's name for the voice, which is what gets stored.
  final String name;

  /// BCP-47 tag of the voice, e.g. `'pt-BR'`.
  final String locale;

  /// Whether the engine sends the text over the network to speak it.
  final bool online;
}

/// Reads text aloud in a [TargetLanguage] with the phone's text-to-speech.
///
/// One utterance at a time: [speak] stops whatever is playing first.
/// [engine] is an engine's package name and null means the phone's default;
/// a voice of null means the engine's default voice for the language.
abstract class SpeechService {
  /// Whether a voice for [language] is installed and usable on [engine].
  Future<bool> isVoiceAvailable(TargetLanguage language, {String? engine});

  /// Package names of the installed text-to-speech engines.
  Future<List<String>> engines();

  /// The voices [engine] has for [language]'s language, any region.
  Future<List<SpeechVoice>> voices(TargetLanguage language, {String? engine});

  /// Stop anything playing, then read [text] in [language] with [engine] and
  /// [voice]. A [voice] the engine no longer has falls back to its default.
  ///
  /// The returned future completes when this utterance ends, whether it
  /// finished, was stopped, or failed.
  Future<void> speak(
    String text,
    TargetLanguage language, {
    String? engine,
    String? voice,
  });

  /// Stop the current utterance, if any.
  Future<void> stop();

  /// Open the system screen for installing voice data. Returns false when no
  /// such screen could be opened.
  Future<bool> openVoiceInstall();
}

/// Whether a voice tagged [locale] speaks [language], in any region.
bool voiceSpeaks(String locale, TargetLanguage language) {
  String primary(String tag) => tag.split(RegExp('[-_]')).first.toLowerCase();
  return primary(locale) == primary(language.code);
}

final _emoji = RegExp(
  r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\u{200D}]',
  unicode: true,
);
final _markdown = RegExp(r'[*_#`~>]');
final _spaces = RegExp(r'\s+');

/// [text] as it should be read: emoji and markdown symbols removed, which a
/// voice would otherwise name or stumble on, and whitespace collapsed.
String speakableText(String text) {
  return text
      .replaceAll(_emoji, ' ')
      .replaceAll(_markdown, '')
      .replaceAll(_spaces, ' ')
      .trim();
}
