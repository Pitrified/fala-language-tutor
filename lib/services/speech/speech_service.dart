import '../../models/target_language.dart';

/// Reads text aloud in a [TargetLanguage] with the phone's text-to-speech.
///
/// One utterance at a time: [speak] stops whatever is playing first.
abstract class SpeechService {
  /// Whether a voice for [language] is installed and usable.
  Future<bool> isVoiceAvailable(TargetLanguage language);

  /// Stop anything playing, then read [text] in [language].
  ///
  /// The returned future completes when this utterance ends, whether it
  /// finished, was stopped, or failed.
  Future<void> speak(String text, TargetLanguage language);

  /// Stop the current utterance, if any.
  Future<void> stop();

  /// Open the system screen for installing voice data. Returns false when no
  /// such screen could be opened.
  Future<bool> openVoiceInstall();
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
