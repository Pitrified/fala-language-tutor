import 'dart:io';

import 'package:fala/build_info.dart';
import 'package:fala/providers/diagnostics_provider.dart';
import 'package:fala/providers/settings_provider.dart';
import 'package:fala/providers/speech_provider.dart';
import 'package:fala/screens/settings/diagnostics_screen.dart';
import 'package:fala/services/diagnostics/diagnostics_log.dart';
import 'package:fala/services/settings/app_settings_repository.dart';
import 'package:fala/services/speech/fake_speech_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late AppSettingsRepository settings;
  late DiagnosticsLog log;
  String? copied;
  var run = 0;

  setUp(() async {
    run++;
    tempDir = await Directory.systemTemp.createTemp('diagnostics_');
    Hive.init(tempDir.path);
    settings = AppSettingsRepository(boxName: 'diagnostics_settings_$run');
    await settings.initialize();
    await settings.setReadRepliesAloud(true);
    log = DiagnosticsLog();
    await log.add('speak button pt-BR engine=default chars=12 finished');
    copied = null;
  });

  tearDown(() async => tempDir.delete(recursive: true));

  /// The device channel answers asynchronously; the widget clock is fake.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsRepositoryProvider.overrideWithValue(settings),
          diagnosticsLogProvider.overrideWithValue(log),
          speechServiceProvider.overrideWithValue(
            FakeSpeechService(engineNames: ['com.example.tts']),
          ),
        ],
        child: const MaterialApp(home: DiagnosticsScreen()),
      ),
    );
    await settle(tester);
  }

  testWidgets('shows the metadata header and the log, and copies both', (
    tester,
  ) async {
    await pumpScreen(tester);
    final text = tester
        .widget<SelectableText>(find.byType(SelectableText))
        .data!;
    expect(text, startsWith('fala diagnostics '));
    expect(text, contains('app $appVersionLabel | unknown device'));
    expect(text, contains('language pt-BR | level A1'));
    expect(text, contains('read aloud on'));
    expect(text, contains('engines com.example.tts'));
    expect(
      text,
      endsWith('speak button pt-BR engine=default chars=12 finished'),
    );

    await tester.tap(find.byTooltip('Copy'));
    await tester.pump();
    expect(copied, text);
    expect(find.text('Diagnostics copied'), findsOneWidget);
  });

  testWidgets('Clear empties the log', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.byTooltip('Clear'));
    await settle(tester);
    expect(log.lines, isEmpty);
    final text = tester
        .widget<SelectableText>(find.byType(SelectableText))
        .data!;
    expect(text, endsWith('(no entries)'));
  });
}
