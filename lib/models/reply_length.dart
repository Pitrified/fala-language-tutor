/// How long the tutor's conversational reply is. Sent to the prompt as the
/// length rule of the same name in `reply_style.json`.
enum ReplyLength { short, normal, long }

/// Labels and parsing for [ReplyLength].
extension ReplyLengthX on ReplyLength {
  /// Name shown in the picker.
  String get label => switch (this) {
    ReplyLength.short => 'Short',
    ReplyLength.normal => 'Normal',
    ReplyLength.long => 'Long',
  };

  /// What the tutor is asked for, shown under the picker.
  String get description => switch (this) {
    ReplyLength.short => 'One or two sentences.',
    ReplyLength.normal => 'Two to four sentences.',
    ReplyLength.long =>
      'Four to six sentences, with a detail or opinion of the tutor\'s own.',
  };

  /// Parses a stored [ReplyLength.name], or null for anything else.
  static ReplyLength? fromName(String? name) {
    for (final length in ReplyLength.values) {
      if (length.name == name) return length;
    }
    return null;
  }
}
