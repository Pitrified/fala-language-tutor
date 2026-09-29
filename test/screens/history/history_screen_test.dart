import 'dart:io';

import 'package:fala/app.dart';
import 'package:fala/models/inference_status.dart';
import 'package:fala/models/target_language.dart';
import 'package:fala/models/tutor_response.dart';
import 'package:fala/providers/conversation_provider.dart';
import 'package:fala/providers/settings_provider.dart';
import 'package:fala/providers/speech_provider.dart';
import 'package:fala/screens/conversation/conversation_screen.dart';
import 'package:fala/screens/history/history_screen.dart';
import 'package:fala/services/conversation/conversation_controller.dart';
import 'package:fala/services/inference/inference_engine.dart';
import 'package:fala/services/inference/structured_stream_engine.dart';
import 'package:fala/services/persistence/conversation_repository.dart';
import 'package:fala/services/prompt/prompt_manager.dart';
import 'package:fala/services/settings/app_settings_repository.dart';
import 'package:fala/services/speech/fake_speech_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
    tempDir = await Directory.systemTemp.createTemp('hive_history_test_');
    Hive.init(tempDir.path);
    repo = ConversationRepository(boxName: 'test_history_convos_$run');
    await repo.initialize();
    settings = AppSettingsRepository(boxName: 'test_history_settings_$run');
    await settings.initialize();
  });

  tearDown(() async {
    for (final c in controllers) {
      await c.dispose();
    }
    controllers.clear();
    await tempDir.delete(recursive: true);
  });

  /// Two conversations with messages ("ciclismo", then "comida") and an empty
  /// one saved last, which the conversation screen opens.
  Future<ConversationController> seeded(WidgetTester tester) async {
    await tester.runAsync(() async {
      final before = newController();
      for (final (topic, message) in [('ciclismo', 'Oi'), ('comida', 'Olá')]) {
        await before.startConversation(
          language: TargetLanguage.ptBr,
          topic: topic,
        );
        await before.sendMessage(message);
        // Ids are millisecond timestamps.
        await Future<void>.delayed(const Duration(milliseconds: 2));
      }
      await before.startConversation(
        language: TargetLanguage.ptBr,
        topic: 'vazio',
      );
    });
    return newController();
  }

  /// Long enough for a page transition to finish.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// The conversation screen with the Conversations page behind the drawer.
  Future<void> openHistory(
    WidgetTester tester,
    ConversationController controller,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const ConversationScreen()),
        GoRoute(
          path: AppRoutes.history,
          builder: (_, _) => const HistoryScreen(),
        ),
      ],
    );
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            speechServiceProvider.overrideWithValue(FakeSpeechService()),
            conversationControllerProvider.overrideWithValue(controller),
            appSettingsRepositoryProvider.overrideWithValue(settings),
            modelSetupNeededProvider.overrideWithValue(false),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await settle(tester);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await settle(tester);
    final tutor = tester.getTopLeft(find.text('Tutor')).dy;
    final entry = tester.getTopLeft(find.text('Conversations')).dy;
    final settingsHeader = tester.getTopLeft(find.text('Settings')).dy;
    expect(tutor < entry && entry < settingsHeader, isTrue);
    await tester.tap(find.text('Conversations'));
    await settle(tester);
  }

  /// Taps [finder] in real time, since what it does writes to Hive.
  Future<void> tapWriting(WidgetTester tester, Finder finder) async {
    await tester.runAsync(() async {
      await tester.tap(finder);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await settle(tester);
  }

  testWidgets('lists the conversations with messages, newest first', (
    tester,
  ) async {
    await openHistory(tester, await seeded(tester));

    expect(find.byType(HistoryScreen), findsOneWidget);
    expect(find.text('vazio'), findsNothing);
    final comida = tester.getTopLeft(find.text('comida')).dy;
    final ciclismo = tester.getTopLeft(find.text('ciclismo')).dy;
    expect(comida, lessThan(ciclismo));
    expect(find.textContaining('2 messages · pt-BR'), findsNWidgets(2));
  });

  testWidgets('the x deletes one conversation', (tester) async {
    await openHistory(tester, await seeded(tester));

    await tapWriting(tester, find.byTooltip('Delete conversation').first);

    expect(find.text('comida'), findsNothing);
    expect(find.text('ciclismo'), findsOneWidget);
    expect(repo.listAll().map((c) => c.topic), isNot(contains('comida')));
  });

  testWidgets('Clear all asks first, then deletes everything', (tester) async {
    final controller = await seeded(tester);
    await openHistory(tester, controller);

    await tester.tap(find.text('Clear all'));
    await settle(tester);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('comida'), findsOneWidget);

    // The delete runs after the dialog closes, in the zone the tap on Clear
    // all started in: start it in real time so the Hive writes complete.
    await tester.runAsync(() async => tester.tap(find.text('Clear all')));
    await settle(tester);
    await tapWriting(tester, find.text('Delete'));

    expect(find.text('No conversations yet.'), findsOneWidget);
    // The open conversation was deleted too, so a new empty one replaced it.
    expect(repo.listAll().map((c) => c.id), [
      controller.currentConversation!.id,
    ]);
  });

  testWidgets('a tap opens the conversation', (tester) async {
    final controller = await seeded(tester);
    await openHistory(tester, controller);

    await tester.tap(find.text('ciclismo'));
    await settle(tester);

    expect(find.byType(HistoryScreen), findsNothing);
    expect(find.text('Oi'), findsOneWidget);
    expect(controller.currentConversation?.topic, 'ciclismo');
  });
}
