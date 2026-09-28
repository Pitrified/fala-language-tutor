import 'package:flutter/services.dart';

import '../../models/app_exception.dart';
import 'reply_style.dart';

/// Manages versioned prompt templates from app assets.
///
/// Prompts are stored as plain text files in `assets/prompts/{name}/vN.txt`.
/// The manager loads the highest-numbered version and substitutes variables.
class PromptManager {
  PromptManager();

  final Map<String, String> _cache = {};
  ReplyStyle? _replyStyle;

  /// Line in a template that separates the developer part above from the
  /// user part below.
  static const userSplit = '\n=== USER ===\n';

  /// Splits a built prompt at [userSplit]. A prompt without the line is all
  /// user message.
  static ({String? developer, String user}) split(String prompt) {
    final at = prompt.indexOf(userSplit);
    if (at < 0) return (developer: null, user: prompt);
    return (
      developer: prompt.substring(0, at),
      user: prompt.substring(at + userSplit.length),
    );
  }

  /// The tutor reply's level guides, samples and length rules, loaded once.
  Future<ReplyStyle> replyStyle() async => _replyStyle ??= ReplyStyle.parse(
    await rootBundle.loadString(
      'assets/prompts/tutor_response/reply_style.json',
    ),
  );

  /// Load a prompt template by name, using the specified version.
  ///
  /// If [version] is null, loads the highest available version.
  /// Templates use {{variable}} syntax for substitution.
  Future<String> loadTemplate({required String name, int? version}) async {
    final key = '$name/v${version ?? "latest"}';
    if (_cache.containsKey(key)) return _cache[key]!;

    final assetPath = version != null
        ? 'assets/prompts/$name/v$version.txt'
        : await _findLatestVersion(name);

    final content = await rootBundle.loadString(assetPath);
    _cache[key] = content;
    return content;
  }

  /// Matches any `{{placeholder}}` left after substitution.
  static final _unresolved = RegExp(r'\{\{([a-z_]+)\}\}');

  /// Build a prompt by loading template and substituting variables.
  ///
  /// Variables in the template like {{user_message}} are replaced with
  /// the corresponding values from [variables].
  ///
  /// Throws [PromptTemplateException] if the template still contains a
  /// placeholder afterwards. Leaving one in would send the literal
  /// `{{target_language}}` to the model, which produces a plausible-looking
  /// reply in the wrong language rather than an error.
  Future<String> buildPrompt({
    required String name,
    required Map<String, String> variables,
    int? version,
  }) async {
    var template = await loadTemplate(name: name, version: version);

    for (final entry in variables.entries) {
      template = template.replaceAll('{{${entry.key}}}', entry.value);
    }

    final leftover = _unresolved
        .allMatches(template)
        .map((m) => m.group(1)!)
        .toSet();
    if (leftover.isNotEmpty) {
      throw PromptTemplateException(
        message:
            'Prompt "$name" has unsubstituted variable(s): '
            '${leftover.join(', ')}.',
      );
    }

    return template;
  }

  /// Find the highest version number for a prompt template.
  Future<String> _findLatestVersion(String name) async {
    // Try versions starting from a reasonable max
    for (var v = 10; v >= 1; v--) {
      final path = 'assets/prompts/$name/v$v.txt';
      try {
        await rootBundle.loadString(path);
        return path;
      } on Object {
        continue;
      }
    }

    throw StateError('No prompt template found for "$name"');
  }

  /// Clear the template cache.
  void clearCache() => _cache.clear();
}
