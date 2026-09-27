import 'dart:io';

import 'package:fala/models/conversation.dart';
import 'package:fala/models/conversation_message.dart';
import 'package:fala/services/persistence/conversation_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late ConversationRepository repo;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    repo = ConversationRepository(boxName: 'test_conversations');
    await repo.initialize();
  });

  tearDown(() async {
    await repo.close();
    await tempDir.delete(recursive: true);
  });

  Conversation makeConversation({required String id, DateTime? updatedAt}) {
    return Conversation(
      id: id,
      createdAt: DateTime(2024),
      updatedAt: updatedAt ?? DateTime(2024),
      messages: [],
    );
  }

  test('save and load a conversation', () async {
    final conv = makeConversation(id: 'abc');
    await repo.save(conv);
    final loaded = repo.load('abc');
    expect(loaded, isNotNull);
    expect(loaded!.id, 'abc');
  });

  test('load nonexistent ID returns null', () {
    expect(repo.load('nonexistent'), isNull);
  });

  test('listAll returns sorted by updatedAt descending', () async {
    await repo.save(
      makeConversation(id: 'old', updatedAt: DateTime(2024, 1, 1)),
    );
    await repo.save(
      makeConversation(id: 'new', updatedAt: DateTime(2024, 6, 1)),
    );

    final all = repo.listAll();
    expect(all, hasLength(2));
    expect(all.first.id, 'new');
    expect(all.last.id, 'old');
  });

  test('appendMessage updates conversation', () async {
    await repo.save(makeConversation(id: 'conv1'));

    final message = ConversationMessage(
      id: 'msg1',
      role: MessageRole.user,
      content: 'Ola',
      timestamp: DateTime(2024, 3, 1),
    );

    final updated = await repo.appendMessage('conv1', message);
    expect(updated, isNotNull);
    expect(updated!.messages, hasLength(1));
    expect(updated.messages.first.content, 'Ola');
  });

  test('delete removes conversation', () async {
    await repo.save(makeConversation(id: 'to_delete'));
    await repo.delete('to_delete');
    expect(repo.load('to_delete'), isNull);
  });

  test('deleteAll clears everything', () async {
    await repo.save(makeConversation(id: 'a'));
    await repo.save(makeConversation(id: 'b'));
    await repo.deleteAll();
    expect(repo.listAll(), isEmpty);
  });

  test('listAll skips an entry it cannot read and keeps the rest', () async {
    final good = makeConversation(id: 'good');
    await repo.save(good);
    // Written by hand, as an older build or a half-written record could leave
    // it: a message with no id, content or timestamp.
    final box = await Hive.openBox<String>('test_conversations');
    await box.put('broken', '{"id":"broken","messages":[{"role":"tutor"}]}');

    final all = repo.listAll();

    expect(all.map((c) => c.id), ['good']);
    expect(repo.unreadableCount, 1);
  });
}
