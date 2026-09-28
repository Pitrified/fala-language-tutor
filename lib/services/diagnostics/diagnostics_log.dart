import 'package:hive/hive.dart';

/// Timestamped lines on what the app did, such as each reply read aloud, to be
/// copied from the Diagnostics page and pasted back after a run on a phone.
///
/// Kept in a Hive box when one is given, so going to Android settings and back
/// does not lose them; in memory otherwise, as in tests. Holds the newest
/// [maxLines] lines. Callers log lengths and choices, never message text.
class DiagnosticsLog {
  DiagnosticsLog({this._box, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  /// How many lines are kept.
  static const int maxLines = 500;

  /// Name of the Hive box [open] uses.
  static const String boxName = 'diagnostics';

  final Box<String>? _box;
  final DateTime Function() _now;
  final List<String> _memory = [];

  /// A log kept in its own Hive box.
  static Future<DiagnosticsLog> open() async =>
      DiagnosticsLog(box: await Hive.openBox<String>(boxName));

  /// The lines, oldest first.
  List<String> get lines => _box?.values.toList() ?? List.of(_memory);

  /// Append [entry], prefixed with the local time, dropping the oldest line
  /// beyond [maxLines].
  Future<void> add(String entry) async {
    final line = '${_stamp(_now())} $entry';
    final box = _box;
    if (box == null) {
      _memory.add(line);
      if (_memory.length > maxLines) {
        _memory.removeRange(0, _memory.length - maxLines);
      }
      return;
    }
    await box.add(line);
    while (box.length > maxLines) {
      await box.deleteAt(0);
    }
  }

  /// Remove every line.
  Future<void> clear() async {
    _memory.clear();
    await _box?.clear();
  }

  static String _stamp(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.month)}-${two(t.day)} '
        '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }
}
