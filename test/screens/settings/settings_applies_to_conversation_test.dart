import 'dart:async';
import 'dart:io';

import 'package:fala/models/cefr_level.dart';
import 'package:fala/models/conversation_message.dart';
import 'package:fala/models/inference_status.dart';
import 'package:fala/models/target_language.dart';
import 'package:fala/models/tutor_response.dart';
import 'package:fala/providers/conversation_provider.dart';
import 'package:fala/providers/service_providers.dart';
import 'package:fala/providers/settings_provider.dart';
import 'package:fala/providers/speech_provider.dart';
import 'package:fala/screens/settings/language_settings_screen.dart';
import 'package:fala/services/conversation/conversation_controller.dart';
import 'package:fala/services/inference/engine_kind.dart';
import 'package:fala/services/inference/inference_engine.dart';
import 'package:fala/services/inference/structured_stream_engine.dart';
import 'package:fala/services/persistence/conversation_repository.dart';
import 'package:fala/services/prompt/prompt_manager.dart';
import 'package:fala/services/settings/app_settings_repository.dart';
import 'package:fala/services/speech/fake_speech_service.dart';
import 'package:fala/services/speech/speech_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class _IdleEngine implements InferenceEngine {
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
      const InferenceFailure(error: 'not used');
  @override
  Stream<String> generateStream(InferenceRequest request) =>
      const Stream.empty();
  @override
  Future<void> dispose() async {}
}

void main() {
  late Directory tempDir;
  late AppSettingsRepository settings;
  late ConversationRepository repo;
  late ConversationController controller;
  late FakeSpeechService speech;
  // Hive keeps a box open by name across tests; a fresh name per test keeps
  // each test off the previous one's box.
  var run = 0;

  setUp(() async {
    run++;
    speech = FakeSpeechService();
    tempDir = await Directory.systemTemp.createTemp('settings_apply_');
    Hive.init(tempDir.path);
    settings = AppSettingsRepository(boxName: 'settings_apply_$run');
    await settings.initialize();
    await settings.setEngineKind(EngineKind.fake);
    repo = ConversationRepository(boxName: 'conversations_apply_$run');
    await repo.initialize();
    controller = ConversationController(
      streamEngine: StructuredStreamEngine<TutorResponse>(
        engine: _IdleEngine(),
        fromJson: TutorResponse.fromJson,
      ),
      repository: repo,
      promptManager: PromptManager(),
    );
    await controller.startConversation(language: TargetLanguage.ptBr);
  });

  tearDown(() async {
    await controller.dispose();
    await tempDir.delete(recursive: true);
  });

  /// Hive writes need real time; the widget clock is fake.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          speechServiceProvider.overrideWithValue(speech),
          appSettingsRepositoryProvider.overrideWithValue(settings),
          conversationRepositoryProvider.overrideWithValue(repo),
          conversationControllerProvider.overrideWithValue(controller),
        ],
        child: const MaterialApp(home: LanguageSettingsScreen()),
      ),
    );
    await settle(tester);
  }

  /// A tap whose handler writes to Hive: dispatched in real time, so the
  /// writes it starts complete instead of waiting on the fake clock forever.
  Future<void> tapReal(WidgetTester tester, Finder finder) async {
    await tester.runAsync(() async {
      await tester.tap(finder);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await settle(tester);
  }

  Future<void> pick(WidgetTester tester, String dropdown, String item) async {
    await tester.tap(find.textContaining(dropdown).first);
    await settle(tester);
    await tapReal(tester, find.textContaining(item).last);
  }

  testWidgets('a level change applies to the open conversation', (
    tester,
  ) async {
    await pumpSettings(tester);
    await pick(
      tester,
      '${CefrLevel.a1.displayName} - ${CefrLevel.a1.description}',
      '${CefrLevel.b2.displayName} - ',
    );

    expect(controller.currentConversation!.cefrLevel, CefrLevel.b2.displayName);
  });

  testWidgets('a language change switches an empty conversation in place', (
    tester,
  ) async {
    final before = controller.currentConversation!.id;
    await pumpSettings(tester);
    await pick(tester, TargetLanguage.ptBr.promptName, 'French');

    expect(find.byType(AlertDialog), findsNothing);
    expect(controller.currentConversation!.id, before);
    expect(controller.currentConversation!.language, TargetLanguage.frFr.code);
  });

  group('with a started conversation', () {
    setUp(() async {
      final id = controller.currentConversation!.id;
      await repo.appendMessage(
        id,
        ConversationMessage(
          id: 'm1',
          role: MessageRole.user,
          content: 'Oi',
          timestamp: DateTime(2026),
        ),
      );
      await controller.loadConversation(id);
    });

    testWidgets('a language change asks before replacing it', (tester) async {
      final before = controller.currentConversation!.id;
      await pumpSettings(tester);
      await pick(tester, TargetLanguage.ptBr.promptName, 'French');

      expect(find.byType(AlertDialog), findsOneWidget);
      await tapReal(tester, find.text('New conversation'));

      expect(controller.currentConversation!.id, isNot(before));
      expect(
        controller.currentConversation!.language,
        TargetLanguage.frFr.code,
      );
      expect(repo.load(before)!.messages, hasLength(1));
    });
  });

  testWidgets('the Speech switch persists, and no warning with a voice', (
    tester,
  ) async {
    // Tall enough for the whole Language page, Speech section included.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await pumpSettings(tester);
    expect(find.text('Install voice'), findsNothing);

    await tapReal(tester, find.text('Read replies aloud'));
    expect(settings.readRepliesAloud(), isTrue);
  });

  testWidgets('without a voice for the language, the Speech section says so', (
    tester,
  ) async {
    // Tall enough for the whole Language page, Speech section included.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    speech.languagesWithVoice.remove(TargetLanguage.ptBr);
    await pumpSettings(tester);

    expect(find.textContaining('no Portuguese voice'), findsOneWidget);
    await tester.tap(find.text('Install voice'));
    await settle(tester);
    expect(speech.installRequests, 1);
  });

  testWidgets('the engine and a voice are picked and used to speak', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    speech = FakeSpeechService(
      engineNames: ['com.example.neural'],
      voiceList: const [
        SpeechVoice(name: 'pt-local', locale: 'pt-BR'),
        SpeechVoice(name: 'pt-cloud', locale: 'pt-BR', online: true),
        SpeechVoice(name: 'es-local', locale: 'es-ES'),
      ],
    );
    await pumpSettings(tester);

    await pick(tester, 'Phone default', 'com.example.neural');
    expect(settings.speechEngine(), 'com.example.neural');

    await tester.tap(find.text('Engine default'));
    await settle(tester);
    expect(find.text('pt-cloud (online)'), findsWidgets);
    expect(find.text('es-local'), findsNothing);
    await tapReal(tester, find.text('pt-local').last);
    expect(settings.speechVoice(TargetLanguage.ptBr), 'pt-local');

    final container = ProviderScope.containerOf(
      tester.element(find.byType(LanguageSettingsScreen)),
    );
    unawaited(
      container
          .read(speechProvider.notifier)
          .play(messageId: 'm1', text: 'Oi', language: TargetLanguage.ptBr),
    );
    await settle(tester);
    expect(speech.spokenWith.last, ('com.example.neural', 'pt-local'));
  });
}
