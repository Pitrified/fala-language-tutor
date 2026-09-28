import 'dart:convert';

import 'package:hive/hive.dart';

import '../../models/conversation.dart';
import '../../models/conversation_message.dart';
import '../logging/app_logger.dart';

/// Hive-backed repository for conversation persistence.
///
/// Stores conversations as JSON strings in a Hive box.
/// Each conversation is keyed by its ID.
class ConversationRepository {
  ConversationRepository({this.boxName = 'conversations'});

  final String boxName;
  late Box<String> _box;

  /// Open the Hive box. Must be called before any other method.
  Future<void> initialize() async {
    _box = await Hive.openBox<String>(boxName);
  }

  /// Save or update a conversation.
  Future<void> save(Conversation conversation) async {
    final json = jsonEncode(conversation.toJson());
    await _box.put(conversation.id, json);
  }

  /// Load a conversation by ID. Returns null if not found.
  Conversation? load(String id) {
    final json = _box.get(id);
    if (json == null) return null;
    return Conversation.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// How many stored entries the last [listAll] could not read.
  int get unreadableCount => _unreadableCount;
  int _unreadableCount = 0;

  /// List all conversations, sorted by updatedAt descending.
  ///
  /// An entry that does not parse, such as one written by an older build, is
  /// skipped and counted in [unreadableCount] rather than failing the whole
  /// list: one bad record would otherwise hide every good conversation.
  List<Conversation> listAll() {
    final conversations = <Conversation>[];
    var unreadable = 0;
    for (final json in _box.values) {
      try {
        conversations.add(
          Conversation.fromJson(jsonDecode(json) as Map<String, dynamic>),
        );
      } on Object catch (error) {
        unreadable++;
        AppLogger.instance.warn('Skipping an unreadable conversation: $error');
      }
    }
    _unreadableCount = unreadable;
    return conversations..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Append a message to an existing conversation.
  ///
  /// Updates the conversation's updatedAt timestamp.
  /// Returns the updated conversation, or null if not found.
  Future<Conversation?> appendMessage(
    String conversationId,
    ConversationMessage message,
  ) async {
    final conversation = load(conversationId);
    if (conversation == null) return null;

    final updated = conversation.copyWith(
      messages: [...conversation.messages, message],
      updatedAt: DateTime.now(),
    );
    await save(updated);
    return updated;
  }

  /// Replace the message with [message]'s id in a conversation, returning
  /// the updated conversation, or null when either is not found.
  Future<Conversation?> replaceMessage(
    String conversationId,
    ConversationMessage message,
  ) async {
    final conversation = load(conversationId);
    if (conversation == null) return null;
    final at = conversation.messages.indexWhere((m) => m.id == message.id);
    if (at < 0) return null;
    final messages = [...conversation.messages]..[at] = message;
    final updated = conversation.copyWith(messages: messages);
    await save(updated);
    return updated;
  }

  /// Delete a conversation by ID.
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Delete all conversations.
  Future<void> deleteAll() async {
    await _box.clear();
  }

  /// Close the Hive box.
  Future<void> close() async {
    await _box.close();
  }
}
