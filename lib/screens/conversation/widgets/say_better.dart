import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/tutor_response.dart';
import '../../../providers/conversation_provider.dart';

/// "Say it better" under a tutor reply: the learner's message rewritten a
/// step richer. Tapping it shows the translation, as on a reply bubble.
class BetterCard extends StatefulWidget {
  const BetterCard({super.key, required this.better});

  /// The rewrite and its translation.
  final ConversationBlock better;

  @override
  State<BetterCard> createState() => _BetterCardState();
}

class _BetterCardState extends State<BetterCard> {
  bool _showTranslation = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final translation = widget.better.translation;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: translation.isEmpty
          ? null
          : () => setState(() => _showTranslation = !_showTranslation),
      child: Container(
        margin: const EdgeInsets.only(left: 8, top: 4, bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withAlpha(100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Say it better',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(widget.better.content),
            if (_showTranslation)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  translation,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Button beside a tutor reply that asks for "say it better" on it, shown
/// when the reply has none yet. A spinner while the request runs; a snackbar
/// when there was nothing to improve or the request failed.
class SayBetterButton extends ConsumerStatefulWidget {
  const SayBetterButton({super.key, required this.messageId});

  /// Id of the tutor reply the rewrite is saved on.
  final String messageId;

  @override
  ConsumerState<SayBetterButton> createState() => _SayBetterButtonState();
}

class _SayBetterButtonState extends ConsumerState<SayBetterButton> {
  bool _loading = false;

  Future<void> _request() async {
    final controller = ref.read(conversationControllerProvider);
    if (controller == null) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);
    final better = await controller.requestBetter(widget.messageId);
    if (mounted) setState(() => _loading = false);
    if (better == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not get a suggestion.')),
      );
    } else if (better.content.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Nothing to improve in that message.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return IconButton(
      visualDensity: VisualDensity.compact,
      tooltip: 'Say it better',
      icon: const Icon(Icons.auto_awesome_outlined, size: 20),
      onPressed: _request,
    );
  }
}
