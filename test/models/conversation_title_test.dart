import 'package:fala/models/conversation.dart';
import 'package:fala/models/conversation_title.dart';
import 'package:flutter_test/flutter_test.dart';

Conversation _with(String topic) => Conversation(
  id: '1',
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  messages: const [],
  topic: topic,
);

void main() {
  test('a short topic is kept whole', () {
    expect(conversationTitle(_with('Food')), 'Food');
  });

  test('a topic of exactly the limit is kept whole', () {
    final topic = 'a' * conversationTitleLength;
    expect(conversationTitle(_with(topic)), topic);
  });

  test('a longer topic is cut with an ellipsis', () {
    expect(
      conversationTitle(_with('Planning a trip to the mountains in winter')),
      'Planning a trip to the mountai...',
    );
  });

  test('an empty topic is "No topic"', () {
    expect(conversationTitle(_with('')), 'No topic');
    expect(conversationTitle(_with('  ')), 'No topic');
  });
}
