import 'package:flutter/material.dart';

import '../../../models/conversation.dart';

/// The choice offered on a cold start when the last conversation has messages:
/// a short summary of it, then "Resume conversation" and "New conversation".
///
/// Presentational: [onResume] and [onNew] do the work.
class ResumeChoice extends StatelessWidget {
  const ResumeChoice({
    super.key,
    required this.conversation,
    required this.onResume,
    required this.onNew,
  });

  /// The conversation that "Resume conversation" opens.
  final Conversation conversation;

  /// Called when the learner picks "Resume conversation".
  final VoidCallback onResume;

  /// Called when the learner picks "New conversation".
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = MaterialLocalizations.of(
      context,
    ).formatMediumDate(conversation.updatedAt.toLocal());
    final count = conversation.messages.length;
    final last = conversation.messages.last.content;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Your last conversation',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                [
                  if (conversation.topic.isNotEmpty) conversation.topic,
                  '$count ${count == 1 ? 'message' : 'messages'}',
                  date,
                ].join(' · '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                last,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onResume,
                child: const Text('Resume conversation'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: onNew,
                child: const Text('New conversation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
