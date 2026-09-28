import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../build_info.dart';
import '../models/cefr_level.dart';
import '../models/target_language.dart';
import 'diagnostics_provider.dart';
import 'settings_provider.dart';
import 'speech_provider.dart';

/// The phone's maker, model and Android version, e.g.
/// `Google Pixel 8 | Android 16 (SDK 36)`, or `unknown device` when the
/// platform cannot say, as in tests.
final deviceSummaryProvider = FutureProvider<String>((ref) async {
  try {
    final info = await const MethodChannel(
      'fala/speech',
    ).invokeMapMethod<String, String>('deviceInfo');
    if (info == null) return 'unknown device';
    return '${info['maker']} ${info['model']} | '
        'Android ${info['release']} (SDK ${info['sdk']})';
  } on PlatformException {
    return 'unknown device';
  } on MissingPluginException {
    return 'unknown device';
  }
});

/// The Diagnostics page's text: a header on the app, the phone and the current
/// choices, then the log. Meant to be pasted back as is, so it describes the
/// run without anyone having to.
final diagnosticsDumpProvider = FutureProvider.autoDispose<String>((ref) async {
  final device = await ref.watch(deviceSummaryProvider.future);
  final engines = await ref.watch(speechEnginesProvider.future);
  final TargetLanguage language = ref.watch(defaultTargetLanguageProvider);
  final CefrLevel level = ref.watch(defaultCefrLevelProvider);
  final readAloud = ref.watch(readRepliesAloudProvider);
  final engine = ref.watch(speechEngineProvider);
  final voice = ref.watch(speechVoiceProvider)[language];
  final inference = ref.watch(selectedEngineKindProvider);
  final lines = ref.read(diagnosticsLogProvider).lines;
  return [
    'fala diagnostics ${_timestamp(DateTime.now())}',
    'app $appVersionLabel | $device',
    [
      'language ${language.code}',
      'level ${level.displayName}',
      'inference ${inference.name}',
      'read aloud ${readAloud ? 'on' : 'off'}',
    ].join(' | '),
    'speech engine ${engine ?? 'default'} | voice ${voice ?? 'default'}',
    'engines ${engines.isEmpty ? 'none reported' : engines.join(', ')}',
    '--',
    if (lines.isEmpty) '(no entries)' else ...lines,
  ].join('\n');
});

/// ISO 8601 local time with its UTC offset, e.g. `2026-09-28T18:04:11+02:00`.
String _timestamp(DateTime t) {
  final offset = t.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final minutes = offset.inMinutes.abs();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${t.toIso8601String().split('.').first}'
      '$sign${two(minutes ~/ 60)}:${two(minutes % 60)}';
}
