import 'conversation.dart';

/// Longest topic shown whole in a conversation's name.
const conversationTitleLength = 30;

/// The name a conversation is listed under: its topic, cut at
/// [conversationTitleLength] characters with `...` appended when cut, or
/// "No topic". The list shows the date beside it, so it is not repeated here.
String conversationTitle(Conversation conversation) {
  final topic = conversation.topic.trim();
  if (topic.isEmpty) return 'No topic';
  if (topic.length <= conversationTitleLength) return topic;
  return '${topic.substring(0, conversationTitleLength).trimRight()}...';
}
