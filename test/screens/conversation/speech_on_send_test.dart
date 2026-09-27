import 'dart:async';
import 'dart:io';

import 'package:fala/models/inference_status.dart';
import 'package:fala/models/target_language.dart';
import 'package:fala/models/tutor_response.dart';
import 'package:fala/providers/conversation_provider.dart';
import 'package:fala/providers/settings_provider.dart';
import 'package:fala/providers/speech_provider.dart';
import 'package:fala/screens/conversation/conversation_screen.dart';
import 'package:fala/services/conversation/conversation_controller.dart';
import 'package:fala/services/inference/inference_engine.dart';
import 'package:fala/services/inference/structured_stream_engine.dart';
import 'package:fala/services/persistence/conversation_repository.dart';
import 'package:fala/services/prompt/prompt_manager.dart';
import 'package:fala/services/speech/fake_speech_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

const _reply =
    '{"correction":{"content":"","translation":"","errors":[]},'
    '"conversation":{"content":"Tudo bem!","translation":"All good!"}}';

class _OneShotEngine implements InferenceEngine {
  @override
  InferenceStatus get status => const InferenceStatus.ready();
  @override
  bool get isReady => true;
  @override
  Stream<InferenceStatus> get statusStream => const Stream.empty();
  @override
  Future<void> initialize() async {}
  @override
  Future<InferenceResult> generate(InferenceRequest request) async =>
      const InferenceSuccess(rawText: _reply);
  @override
  Stream<String> generateStream(InferenceRequest request) async* {
    yield _reply;
  }

  @override
  Future<void> dispose() async {}
}

class _FakePromptManager extends PromptManager {
  @override
  Future<String> buildPrompt({
    required String name,
    required Map<String, String> variables,
    int? version,
  }) async => 'fake prompt';
}

/// "Read replies aloud" fixed for a test, without a settings box.
class _FixedReadAloud extends ReadRepliesAloudNotifier {
  _FixedReadAloud(this.value);

  final bool value;

  @override
  bool build() => value;
}

void main() {
  late ConversationController controller;
  late ConversationRepository repo;
  late Directory tempDir;
  late FakeSpeechService speech;
  var run = 0;

  setUp(() async {
    run++;
    tempDir = await Directory.systemTemp.createTemp('speech_on_send_');
    Hive.init(tempDir.path);
    repo = ConversationRepository(boxName: 'speech_on_send_$run');
    await repo.initialize();
    controller = ConversationController(
      streamEngine: StructuredStreamEngine<TutorResponse>(
        engine: _OneShotEngine(),
        fromJson: TutorResponse.fromJson,
      ),
      repository: repo,
      promptManager: _FakePromptManager(),
    );
    await controller.startConversation(language: TargetLanguage.ptBr);
    speech = FakeSpeechService();
  });

  tearDown(() async {
    await controller.dispose();
    await repo.close();
    await tempDir.delete(recursive: true);
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required bool readAloud,
  }) async {
    // The test binding starts with no lifecycle state; the app is in front.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          speechServiceProvider.overrideWithValue(speech),
          conversationControllerProvider.overrideWithValue(controller),
          modelSetupNeededProvider.overrideWithValue(false),
          readRepliesAloudProvider.overrideWith(
            () => _FixedReadAloud(readAloud),
          ),
        ],
        child: const MaterialApp(home: ConversationScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Type [text] and tap send; the reply streams in real time.
  Future<void> send(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.runAsync(() async {
      await tester.tap(find.byIcon(Icons.send));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('sending stops the reply being read', (tester) async {
    await pumpScreen(tester, readAloud: false);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConversationScreen)),
    );
    // Not awaited: it stays pending while the reply plays.
    unawaited(
      container
          .read(speechProvider.notifier)
          .play(messageId: 'old', text: 'Oi', language: TargetLanguage.ptBr),
    );
    expect(speech.isSpeaking, isTrue);

    await send(tester, 'Oi');
    expect(speech.stopCount, greaterThanOrEqualTo(1));
    expect(speech.spoken, hasLength(1), reason: 'auto-read is off');
  });

  testWidgets('with read aloud on, the new reply is read in its language', (
    tester,
  ) async {
    await pumpScreen(tester, readAloud: true);
    await send(tester, 'Oi');

    expect(speech.spoken.single, ('Tudo bem!', TargetLanguage.ptBr));
    expect(find.byTooltip('Stop reading'), findsOneWidget);
  });

  testWidgets('with read aloud on but no voice, the reply stays silent', (
    tester,
  ) async {
    speech.voices.remove(TargetLanguage.ptBr);
    await pumpScreen(tester, readAloud: true);
    await send(tester, 'Oi');

    expect(speech.spoken, isEmpty);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('every tutor reply has a speaker button', (tester) async {
    await pumpScreen(tester, readAloud: false);
    await send(tester, 'Oi');

    expect(find.byTooltip('Read aloud'), findsOneWidget);
  });

  testWidgets('leaving the app stops the reading, the notification shade not', (
    tester,
  ) async {
    await pumpScreen(tester, readAloud: true);
    await send(tester, 'Oi');
    expect(speech.isSpeaking, isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(speech.isSpeaking, isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump();
    expect(speech.isSpeaking, isFalse);
  });
}
