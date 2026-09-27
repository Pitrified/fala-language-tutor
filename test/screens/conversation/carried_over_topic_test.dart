import 'dart:io';

import 'package:fala/models/inference_status.dart';
import 'package:fala/models/target_language.dart';
import 'package:fala/models/tutor_response.dart';
import 'package:fala/providers/conversation_provider.dart';
import 'package:fala/providers/settings_provider.dart';
import 'package:fala/screens/conversation/conversation_screen.dart';
import 'package:fala/services/conversation/conversation_controller.dart';
import 'package:fala/services/inference/inference_engine.dart';
import 'package:fala/services/inference/structured_stream_engine.dart';
import 'package:fala/services/persistence/conversation_repository.dart';
import 'package:fala/services/prompt/prompt_manager.dart';
import 'package:fala/services/settings/app_settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

const _olaJson =
    '{"correction":{"content":"","translation":"","errors":[]},'
    '"conversation":{"content":"Ola!","translation":"Hello!"}}';

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
      const InferenceSuccess(rawText: _olaJson);
  @override
  Stream<String> generateStream(InferenceRequest request) async* {
    yield _olaJson;
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ConversationController controller;
  late ConversationRepository repo;
  late AppSettingsRepository settings;
  late Directory tempDir;
  // Hive keeps a box open by name across tests; a fresh name per test keeps
  // each test off the previous one's box.
  var run = 0;

  setUp(() async {
    run++;
    tempDir = await Directory.systemTemp.createTemp('hive_topic_line_test_');
    Hive.init(tempDir.path);

    repo = ConversationRepository(boxName: 'test_topic_line_convos_$run');
    await repo.initialize();
    settings = AppSettingsRepository(boxName: 'test_topic_line_settings_$run');
    await settings.initialize();

    controller = ConversationController(
      streamEngine: StructuredStreamEngine<TutorResponse>(
        engine: _OneShotEngine(),
        fromJson: TutorResponse.fromJson,
      ),
      repository: repo,
      promptManager: _FakePromptManager(),
    );
  });

  tearDown(() async {
    await controller.dispose();
    await tempDir.delete(recursive: true);
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationControllerProvider.overrideWithValue(controller),
          appSettingsRepositoryProvider.overrideWithValue(settings),
        ],
        child: const MaterialApp(home: ConversationScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('a carried-over topic says where it came from', (tester) async {
    await tester.runAsync(
      () => controller.startConversation(
        language: TargetLanguage.ptBr,
        topic: 'ciclismo',
      ),
    );
    await pumpScreen(tester);

    expect(
      find.text('Topic: ciclismo, from your last conversation'),
      findsOneWidget,
    );
  });

  testWidgets('a topic picked for this conversation is shown without origin', (
    tester,
  ) async {
    await tester.runAsync(
      () => controller.startConversation(
        language: TargetLanguage.ptBr,
        topic: 'ciclismo',
      ),
    );
    await pumpScreen(tester);
    await tester.runAsync(() => controller.setTopic('jazz'));
    await tester.pump();

    expect(find.text('Topic: jazz'), findsOneWidget);
    expect(find.textContaining('from your last conversation'), findsNothing);
  });

  testWidgets('no topic, no topic line', (tester) async {
    await tester.runAsync(
      () => controller.startConversation(language: TargetLanguage.ptBr),
    );
    await pumpScreen(tester);

    expect(find.textContaining('Topic:'), findsNothing);
  });

  testWidgets('the line goes once the first message is sent', (tester) async {
    await tester.runAsync(
      () => controller.startConversation(
        language: TargetLanguage.ptBr,
        topic: 'ciclismo',
      ),
    );
    await pumpScreen(tester);
    await tester.runAsync(() => controller.sendMessage('Oi'));
    await tester.pump();

    expect(find.textContaining('Topic:'), findsNothing);
    expect(find.textContaining('Say something'), findsNothing);
  });
}
