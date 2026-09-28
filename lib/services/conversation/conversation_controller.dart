import 'dart:async';

import '../../models/app_exception.dart';
import '../../models/cefr_level.dart';
import '../../models/conversation.dart';
import '../../models/conversation_message.dart';
import '../../models/target_language.dart';
import '../../models/tutor_response.dart';
import '../inference/inference_engine.dart';
import '../inference/structured_stream_engine.dart';
import '../logging/app_logger.dart';
import '../persistence/conversation_repository.dart';
import '../prompt/prompt_manager.dart';
import 'correction_filter.dart';

/// Orchestrates the conversation loop between user and tutor.
///
/// Responsibilities:
/// - Build prompt from template + history + user message
/// - Drive the structured streaming engine, exposing live partial deltas
/// - Persist the final message to repository (from the terminal delta's value)
/// - Expose conversation state for UI consumption
class ConversationController {
  ConversationController({
    required this.streamEngine,
    required this.repository,
    required this.promptManager,
    this.maxHistoryMessages = 10,
  });

  /// Streaming engine for the in-flight turn. Its terminal delta carries the
  /// same fully-typed value the one-shot path would produce, which is what we
  /// persist.
  final StructuredStreamEngine<TutorResponse> streamEngine;
  final ConversationRepository repository;
  final PromptManager promptManager;
  final int maxHistoryMessages;

  /// Language the corrections, explanations and translations are written in.
  ///
  /// Fixed at English for now: the user's own language is not a setting yet, so
  /// there is nothing to read it from (`docs/functional-specs.md`). The
  /// prompt takes it as a variable, so exposing it later is a call-site change
  /// and not a template edit.
  static const String explanationLanguage = 'English';

  Conversation? _currentConversation;
  final _conversationController = StreamController<Conversation?>.broadcast();

  /// Live, ephemeral partial deltas for the in-flight tutor turn. Events flow
  /// only during a [sendMessage]; the UI overlays them on top of the committed
  /// [conversationStream]. Broadcast so it can be (re)bound across turns.
  final _streamingReplyController =
      StreamController<StructuredDelta<TutorResponse>>.broadcast();

  bool _isSending = false;
  bool _topicCarriedOver = false;

  /// Stream of conversation updates for reactive UI.
  Stream<Conversation?> get conversationStream =>
      _conversationController.stream;

  /// Live partial deltas for the in-flight tutor reply (empty between sends).
  Stream<StructuredDelta<TutorResponse>> get streamingReply =>
      _streamingReplyController.stream;

  /// Current active conversation.
  Conversation? get currentConversation => _currentConversation;

  /// Whether the active conversation's topic is the one it was started with.
  ///
  /// True after [startConversation] with a non-empty topic, since every caller
  /// passes the default topic, which is the last one used. False once
  /// [setTopic] is called, and for a conversation that was resumed or loaded
  /// rather than started. Not persisted.
  bool get topicCarriedOver => _topicCarriedOver;

  /// Start a new conversation.
  Future<Conversation> startConversation({
    TargetLanguage language = TargetLanguage.ptBr,
    CefrLevel cefrLevel = CefrLevel.a1,
    String topic = '',
  }) async {
    final now = DateTime.now();
    final conversation = Conversation(
      id: now.millisecondsSinceEpoch.toString(),
      createdAt: now,
      updatedAt: now,
      messages: [],
      language: language.code,
      cefrLevel: cefrLevel.displayName,
      topic: topic,
    );
    await repository.save(conversation);
    _currentConversation = conversation;
    _topicCarriedOver = topic.isNotEmpty;
    _conversationController.add(conversation);
    return conversation;
  }

  /// Resume the most recently updated conversation, or start a new one.
  ///
  /// The last conversation is resumed when it is in [language], whether or
  /// not it has messages, so reopening the app neither drops the conversation
  /// nor adds an empty one each time. When it is in another language, because
  /// the default changed since, a new conversation starts in [language] with
  /// [cefrLevel] and [topic], and the old one stays saved. A conversation's
  /// language is fixed once it has messages, so it is never switched here.
  Future<Conversation> resumeOrStartConversation({
    required TargetLanguage language,
    required CefrLevel cefrLevel,
    String topic = '',
  }) async {
    final latest = _latestIn(language);
    if (latest != null) {
      _currentConversation = latest;
      _topicCarriedOver = false;
      _conversationController.add(latest);
      return latest;
    }
    return startConversation(
      language: language,
      cefrLevel: cefrLevel,
      topic: topic,
    );
  }

  /// The conversation [resumeOrStartConversation] would open for [language],
  /// when it has messages; `null` when it would start a new one or open an
  /// empty one. Opens nothing, so a caller can offer the choice first.
  Conversation? resumableConversation(TargetLanguage language) {
    final latest = _latestIn(language);
    return latest == null || latest.messages.isEmpty ? null : latest;
  }

  /// The most recently updated conversation, when it is in [language].
  Conversation? _latestIn(TargetLanguage language) {
    final saved = repository.listAll();
    final latest = saved.isEmpty ? null : saved.first;
    return latest?.language == language.code ? latest : null;
  }

  /// Load an existing conversation by ID.
  Future<void> loadConversation(String id) async {
    _currentConversation = repository.load(id);
    _topicCarriedOver = false;
    _conversationController.add(_currentConversation);
  }

  /// Update the CEFR level of the active conversation without restarting it.
  ///
  /// The new level is persisted to the repository and is used by the very
  /// next prompt. Returns immediately if there is no active conversation or
  /// the level is unchanged.
  Future<void> setCefrLevel(CefrLevel level) async {
    final current = _currentConversation;
    if (current == null) return;
    final newLevel = level.displayName;
    if (current.cefrLevel == newLevel) return;
    final updated = current.copyWith(
      cefrLevel: newLevel,
      updatedAt: DateTime.now(),
    );
    await repository.save(updated);
    _currentConversation = updated;
    _conversationController.add(updated);
  }

  /// Update the topic of the active conversation without restarting it.
  ///
  /// Empty string clears the topic. Trims [topic] before persisting. Clears
  /// [topicCarriedOver], also when [topic] is the one already set.
  Future<void> setTopic(String topic) async {
    final current = _currentConversation;
    if (current == null) return;
    final trimmed = topic.trim();
    if (current.topic == trimmed) {
      if (_topicCarriedOver) {
        _topicCarriedOver = false;
        _conversationController.add(current);
      }
      return;
    }
    _topicCarriedOver = false;
    final updated = current.copyWith(topic: trimmed, updatedAt: DateTime.now());
    await repository.save(updated);
    _currentConversation = updated;
    _conversationController.add(updated);
  }

  /// Set the target language of the active conversation.
  ///
  /// Only valid while the conversation is still empty: once it has messages the
  /// history is in the old language, so the caller starts a new conversation
  /// instead of switching this one. Throws [LanguageLockedException] in that
  /// case. Returns immediately if there is no active conversation or the
  /// language is unchanged.
  Future<void> setLanguage(TargetLanguage language) async {
    final current = _currentConversation;
    if (current == null) return;
    if (current.language == language.code) return;
    if (current.messages.isNotEmpty) {
      throw LanguageLockedException(
        message:
            'Cannot switch to ${language.displayName}: this conversation '
            'already has ${current.messages.length} message(s). Start a new '
            'conversation instead.',
      );
    }
    final updated = current.copyWith(
      language: language.code,
      updatedAt: DateTime.now(),
    );
    await repository.save(updated);
    _currentConversation = updated;
    _conversationController.add(updated);
  }

  /// Send a user message and get a tutor response.
  ///
  /// Streams partial deltas to [streamingReply] as the reply arrives, then
  /// persists the final tutor message built from the terminal delta's typed
  /// value (identical to the one-shot result). Returns the tutor's
  /// ConversationMessage, or null if there is no active conversation or a send
  /// is already in flight (concurrent sends are ignored; the UI also gates).
  Future<ConversationMessage?> sendMessage(String content) async {
    if (_currentConversation == null) return null;
    if (_isSending) return null;
    _isSending = true;

    try {
      final userMessage = ConversationMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.user,
        content: content,
        timestamp: DateTime.now(),
      );

      _currentConversation = await repository.appendMessage(
        _currentConversation!.id,
        userMessage,
      );
      _conversationController.add(_currentConversation);

      // Build prompt
      final language =
          TargetLanguageX.fromCode(_currentConversation!.language) ??
          TargetLanguage.ptBr;
      final cefrLevel = _currentConversation!.cefrLevel;
      final style = await promptManager.replyStyle();
      final replyLevel = style.replyLevel(cefrLevel);
      final prompt = await promptManager.buildPrompt(
        name: 'tutor_response',
        variables: {
          'target_language': language.promptName,
          'explanation_language': explanationLanguage,
          'cefr_level': cefrLevel,
          'reply_level': replyLevel,
          'level_guide': style.levelGuide(replyLevel),
          'reply_samples': style.samples(language.code, replyLevel),
          'length_rule': style.lengthRule('normal'),
          'topic': _currentConversation!.topic,
          'user_message': content,
          'conversation_history': _formatHistory(),
        },
      );

      final parts = PromptManager.split(prompt);

      // Drive the streaming engine: forward each partial delta to the live
      // channel and remember the terminal one for persistence.
      StructuredDelta<TutorResponse>? terminal;
      await for (final delta in streamEngine.generateStream(
        InferenceRequest(prompt: parts.user, developerPrompt: parts.developer),
      )) {
        if (!_streamingReplyController.isClosed) {
          _streamingReplyController.add(delta);
        }
        if (delta.isTerminal) terminal = delta;
      }

      final (replyContent, tutorResponse) = _resolveReply(terminal, content);

      final tutorMessage = ConversationMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.tutor,
        content: replyContent,
        timestamp: DateTime.now(),
        tutorResponse: tutorResponse,
      );

      _currentConversation = await repository.appendMessage(
        _currentConversation!.id,
        tutorMessage,
      );
      _conversationController.add(_currentConversation);
      return tutorMessage;
    } finally {
      _isSending = false;
    }
  }

  /// Map the terminal delta to the persisted reply: typed success -> reply text
  /// + value; either failure kind -> an error line.
  ///
  /// A parse failure used to be shown as the model's raw text, on the grounds
  /// that something beats nothing. Watching it happen on a device changed that
  /// (`docs/library/structured-output-system.md`): the learner saw model
  /// prose in English presented as the tutor's reply, with no correction card and
  /// no sign of failure, which reads as the tutor answering rather than as a
  /// broken turn. The raw text still goes to the log, where it is useful.
  (String, TutorResponse?) _resolveReply(
    StructuredDelta<TutorResponse>? terminal,
    String userMessage,
  ) {
    if (terminal == null) {
      return ('Error generating response: no response received', null);
    }
    if (terminal.isComplete && terminal.value != null) {
      final value = dropNoOpCorrections(terminal.value!, userMessage);
      return (value.conversation.content, value);
    }
    final failure = terminal.failure;
    if (failure != null) {
      if (failure.kind == StructuredFailureKind.parse) {
        AppLogger.instance.warn(
          'Unparseable tutor reply, showing an error line instead: '
          '${failure.rawText}',
        );
      }
      return switch (failure.kind) {
        StructuredFailureKind.parse => (
          'Error generating response: '
              'the reply was not in the expected format.',
          null,
        ),
        StructuredFailureKind.inference => (
          'Error generating response: ${failure.error}',
          null,
        ),
      };
    }
    return ('Error generating response: unknown', null);
  }

  /// Format recent history for prompt context.
  String _formatHistory() {
    if (_currentConversation == null) return '';
    final messages = _currentConversation!.messages;
    final recent = messages.length > maxHistoryMessages
        ? messages.sublist(messages.length - maxHistoryMessages)
        : messages;
    return recent
        .map((m) {
          final role = m.role == MessageRole.user ? 'User' : 'Tutor';
          return '$role: ${m.content}';
        })
        .join('\n');
  }

  /// Dispose resources.
  Future<void> dispose() async {
    await _conversationController.close();
    await _streamingReplyController.close();
  }
}
