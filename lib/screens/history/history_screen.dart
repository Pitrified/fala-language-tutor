import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/conversation.dart';
import '../../models/conversation_title.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/settings_provider.dart';

/// The saved conversations with messages, most recently used first.
///
/// A tap pops the page with the conversation, for the conversation screen to
/// open. The x on a row deletes it; Clear all deletes every conversation after
/// a confirmation. Deleting the open conversation starts a new one with the
/// current defaults.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<Conversation> _conversations = const [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final controller = ref.read(conversationControllerProvider);
    setState(() => _conversations = controller?.history() ?? const []);
  }

  Future<void> _delete(Conversation conversation) async {
    final controller = ref.read(conversationControllerProvider);
    if (controller == null) return;
    await controller.deleteConversation(
      conversation.id,
      language: ref.read(defaultTargetLanguageProvider),
      cefrLevel: ref.read(defaultCefrLevelProvider),
      topic: ref.read(defaultTopicProvider),
    );
    if (mounted) _reload();
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all conversations?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final controller = ref.read(conversationControllerProvider);
    if (controller == null) return;
    await controller.deleteAllConversations(
      language: ref.read(defaultTargetLanguageProvider),
      cefrLevel: ref.read(defaultCefrLevelProvider),
      topic: ref.read(defaultTopicProvider),
    );
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        actions: [
          TextButton(
            onPressed: _conversations.isEmpty ? null : _clearAll,
            child: const Text('Clear all'),
          ),
        ],
      ),
      body: _conversations.isEmpty
          ? const Center(child: Text('No conversations yet.'))
          : ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conversation = _conversations[index];
                final count = conversation.messages.length;
                return ListTile(
                  title: Text(
                    conversationTitle(conversation),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    [
                      localizations.formatMediumDate(
                        conversation.updatedAt.toLocal(),
                      ),
                      '$count ${count == 1 ? 'message' : 'messages'}',
                      conversation.language,
                    ].join(' · '),
                  ),
                  trailing: IconButton(
                    tooltip: 'Delete conversation',
                    icon: const Icon(Icons.close),
                    onPressed: () => _delete(conversation),
                  ),
                  onTap: () => context.pop(conversation),
                );
              },
            ),
    );
  }
}
