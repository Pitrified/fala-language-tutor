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

  late ConversationRepository repo;
  late AppSettingsRepository settings;
  late Directory tempDir;
  final controllers = <ConversationController>[];
  // Hive keeps a box open by name across tests; a fresh name per test keeps
  // each test off the previous one's box.
  var run = 0;

  ConversationController newController() {
    final c = ConversationController(
      streamEngine: StructuredStreamEngine<TutorResponse>(
        engine: _OneShotEngine(),
        fromJson: TutorResponse.fromJson,
      ),
      repository: repo,
      promptManager: _FakePromptManager(),
    );
    controllers.add(c);
    return c;
  }

  setUp(() async {
    run++;
    tempDir = await Directory.systemTemp.createTemp('hive_resume_test_');
    Hive.init(tempDir.path);
    repo = ConversationRepository(boxName: 'test_resume_convos_$run');
    await repo.initialize();
    settings = AppSettingsRepository(boxName: 'test_resume_settings_$run');
    await settings.initialize();
  });

  tearDown(() async {
    for (final c in controllers) {
      await c.dispose();
    }
    controllers.clear();
    await tempDir.delete(recursive: true);
  });

  /// What the app finds on disk after it was closed: a controller that has
  /// nothing open, over the conversations saved by an earlier one.
  Future<ConversationController> reopened(
    WidgetTester tester, {
    required bool withMessages,
  }) async {
    await tester.runAsync(() async {
      final before = newController();
      await before.startConversation(
        language: TargetLanguage.ptBr,
        topic: 'ciclismo',
      );
      if (withMessages) await before.sendMessage('Oi');
    });
    return newController();
  }

  Future<void> pumpScreen(
    WidgetTester tester,
    ConversationController controller,
  ) async {
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

  testWidgets('a last conversation with messages offers the choice', (
    tester,
  ) async {
    final controller = await reopened(tester, withMessages: true);
    await pumpScreen(tester, controller);

    expect(find.text('Your last conversation'), findsOneWidget);
    expect(find.textContaining('ciclismo'), findsOneWidget);
    expect(find.text('Resume conversation'), findsOneWidget);
    expect(find.text('New conversation'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(controller.currentConversation, isNull);
  });

  testWidgets('resume opens the last conversation', (tester) async {
    final controller = await reopened(tester, withMessages: true);
    await pumpScreen(tester, controller);

    await tester.tap(find.text('Resume conversation'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Your last conversation'), findsNothing);
    expect(find.text('Oi'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(controller.currentConversation?.messages, hasLength(2));
  });

  testWidgets('new starts an empty conversation and keeps the old one', (
    tester,
  ) async {
    final controller = await reopened(tester, withMessages: true);
    await pumpScreen(tester, controller);

    await tester.runAsync(() async {
      await tester.tap(find.text('New conversation'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();

    expect(find.text('Your last conversation'), findsNothing);
    expect(find.text('Say something in Portuguese!'), findsOneWidget);
    expect(controller.currentConversation?.messages, isEmpty);
    expect(repo.listAll(), hasLength(2));
  });

  testWidgets('an empty last conversation opens with no choice', (
    tester,
  ) async {
    final controller = await reopened(tester, withMessages: false);
    await tester.runAsync(() => pumpScreen(tester, controller));
    await tester.pump();

    expect(find.text('Your last conversation'), findsNothing);
    expect(find.text('Say something in Portuguese!'), findsOneWidget);
    expect(repo.listAll(), hasLength(1));
  });
}
