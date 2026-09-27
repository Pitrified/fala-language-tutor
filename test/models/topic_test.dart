import 'package:fala/models/topic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Topic equality is value-based', () {
    expect(const Topic(value: 'food'), const Topic(value: 'food'));
    expect(
      const Topic(value: 'food', isCustom: true),
      const Topic(value: 'food'),
    );
  });

  test('Topic.none is empty', () {
    expect(Topic.none.isEmpty, isTrue);
    expect(Topic.none.value, '');
  });

  test('kSuggestedTopics is non-empty and unique', () {
    expect(kSuggestedTopics, isNotEmpty);
    final values = kSuggestedTopics.map((t) => t.value).toSet();
    expect(values.length, kSuggestedTopics.length);
  });

  group('pushRecentTopic', () {
    test('puts a new topic first', () {
      expect(pushRecentTopic(['a', 'b'], 'c'), ['c', 'a', 'b']);
    });

    test('moves a topic already in the list to the top', () {
      expect(pushRecentTopic(['a', 'b', 'c'], 'c'), ['c', 'a', 'b']);
    });

    test('trims before comparing', () {
      expect(pushRecentTopic(['a', 'b'], '  b '), ['b', 'a']);
    });

    test('drops the oldest past the cap', () {
      final full = ['1', '2', '3', '4', '5'];
      expect(full.length, kRecentTopicsCap);
      expect(pushRecentTopic(full, '6'), ['6', '1', '2', '3', '4']);
    });

    test('ignores the empty topic and suggested topics', () {
      expect(pushRecentTopic(['a'], '   '), ['a']);
      expect(pushRecentTopic(['a'], kSuggestedTopics.first.value), ['a']);
    });
  });
}
