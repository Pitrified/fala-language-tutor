import 'package:flutter/material.dart';

import '../../../models/topic.dart';

/// Bottom sheet for picking a [Topic].
///
/// Layout: a `TextField` at the top with an "Apply" button for a custom topic,
/// then the [recent] custom topics, newest first, then [kSuggestedTopics], in
/// one scrollable list. A recent topic's remove button calls [onRemoveRecent]
/// and drops it from the sheet without closing it. Returns the picked [Topic],
/// or `null` if the user dismissed the sheet.
Future<Topic?> showTopicPickerSheet(
  BuildContext context, {
  required Topic current,
  List<String> recent = const [],
  Future<void> Function(String topic)? onRemoveRecent,
}) {
  return showModalBottomSheet<Topic>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
      ),
      child: _TopicPickerBody(
        current: current,
        recent: recent,
        onRemoveRecent: onRemoveRecent,
      ),
    ),
  );
}

class _TopicPickerBody extends StatefulWidget {
  const _TopicPickerBody({
    required this.current,
    required this.recent,
    required this.onRemoveRecent,
  });

  final Topic current;
  final List<String> recent;
  final Future<void> Function(String topic)? onRemoveRecent;

  @override
  State<_TopicPickerBody> createState() => _TopicPickerBodyState();
}

class _TopicPickerBodyState extends State<_TopicPickerBody> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.current.isCustom ? widget.current.value : '',
  );
  late final List<String> _recent = List.of(widget.recent);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;
    Navigator.of(context).pop(Topic(value: raw, isCustom: true));
  }

  void _remove(String topic) {
    setState(() => _recent.remove(topic));
    widget.onRemoveRecent?.call(topic);
  }

  Widget _topicTile(Topic topic, {Widget? trailing}) {
    final isSelected = topic == widget.current;
    return ListTile(
      title: Text(topic.value),
      trailing: trailing ?? (isSelected ? const Icon(Icons.check) : null),
      selected: isSelected,
      onTap: () => Navigator.of(context).pop(topic),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('Pick a topic', style: theme.textTheme.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Custom topic',
                        hintText: 'e.g. ciclismo',
                      ),
                      onSubmitted: (_) => _apply(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _apply, child: const Text('Apply')),
                ],
              ),
            ),
            if (!widget.current.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(Topic.none),
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear topic'),
                  ),
                ),
              ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                children: [
                  if (_recent.isNotEmpty) ...[
                    _sectionLabel('Recent'),
                    for (final value in _recent)
                      _topicTile(
                        Topic(value: value, isCustom: true),
                        trailing: IconButton(
                          tooltip: 'Remove $value',
                          icon: const Icon(Icons.close),
                          onPressed: () => _remove(value),
                        ),
                      ),
                    const Divider(height: 1),
                    _sectionLabel('Suggestions'),
                  ],
                  for (final t in kSuggestedTopics) _topicTile(t),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
