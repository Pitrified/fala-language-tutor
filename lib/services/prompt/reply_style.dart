import 'dart:convert';

/// How the tutor's reply is shaped, per level and length, from
/// `assets/prompts/tutor_response/reply_style.json`.
///
/// The same file feeds the prompt lab, so what the app sends is what was
/// compared there (`docs/prompt-engineering.md`).
class ReplyStyle {
  ReplyStyle._(
    this._replyLevel,
    this._levelGuide,
    this._samples,
    this._lengthRule,
  );

  /// Parses the JSON text of `reply_style.json`.
  factory ReplyStyle.parse(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    List<String> strings(Object? list) =>
        (list! as List<dynamic>).cast<String>();
    return ReplyStyle._(
      (json['reply_level'] as Map<String, dynamic>).cast<String, String>(),
      (json['level_guide'] as Map<String, dynamic>).map(
        (level, lines) => MapEntry(level, strings(lines)),
      ),
      (json['samples'] as Map<String, dynamic>).map(
        (language, byLevel) => MapEntry(
          language,
          (byLevel as Map<String, dynamic>).map(
            (level, lines) => MapEntry(level, strings(lines)),
          ),
        ),
      ),
      (json['length_rule'] as Map<String, dynamic>).cast<String, String>(),
    );
  }

  final Map<String, String> _replyLevel;
  final Map<String, List<String>> _levelGuide;
  final Map<String, Map<String, List<String>>> _samples;
  final Map<String, String> _lengthRule;

  /// The level the reply is written at for a learner at [cefrLevel]. It can
  /// be higher: the model writes a level below the one it is asked for at the
  /// top of the scale.
  String replyLevel(String cefrLevel) => _replyLevel[cefrLevel] ?? cefrLevel;

  /// The guide for [level], as indented `- ` lines.
  String levelGuide(String level) => _bullets(_levelGuide[level] ?? const []);

  /// Sample replies in [languageCode] at [level] with the line introducing
  /// them, or an empty string when there are none for that language.
  String samples(String languageCode, String level) {
    final lines = _samples[languageCode]?[level];
    if (lines == null || lines.isEmpty) return '';
    return 'Replies at $level level. Match their vocabulary, grammar and '
        'sentence length, not their content:\n${_bullets(lines)}';
  }

  /// The length rule named [length] (`short`, `normal`, `long`).
  String lengthRule(String length) => _lengthRule[length] ?? '';

  static String _bullets(List<String> lines) =>
      lines.map((line) => '  - $line').join('\n');
}
