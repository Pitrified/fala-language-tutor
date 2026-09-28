import 'package:fala/services/diagnostics/diagnostics_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stamps each line with the local time', () async {
    final log = DiagnosticsLog(now: () => DateTime(2026, 9, 28, 8, 5, 3));
    await log.add('engine default');
    expect(log.lines, ['09-28 08:05:03 engine default']);
  });

  test('keeps only the newest lines, oldest first', () async {
    final log = DiagnosticsLog();
    for (var i = 0; i < DiagnosticsLog.maxLines + 3; i++) {
      await log.add('line $i');
    }
    expect(log.lines, hasLength(DiagnosticsLog.maxLines));
    expect(log.lines.first, endsWith('line 3'));
    expect(log.lines.last, endsWith('line ${DiagnosticsLog.maxLines + 2}'));
  });

  test('clear empties it', () async {
    final log = DiagnosticsLog();
    await log.add('x');
    await log.clear();
    expect(log.lines, isEmpty);
  });
}
