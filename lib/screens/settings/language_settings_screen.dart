import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/cefr_level.dart';
import '../../models/target_language.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/settings_provider.dart';
import 'widgets/language_switch.dart';

/// Language settings: the language being learned and the CEFR level. Both
/// apply to the open conversation as well as to new ones.
class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Language', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'The language you are learning. The open conversation switches too: '
            'an empty one in place, one with messages by starting a new '
            'conversation after you confirm.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          const _LanguageDropdown(),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          Text('CEFR level', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Applies to the open conversation from the next message, and to '
            'new conversations.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          const _CefrDropdown(),
        ],
      ),
    );
  }
}

/// Default target language. Built like [_CefrDropdown], with the language's own
/// name under the dropdown so the user recognises it.
class _LanguageDropdown extends ConsumerWidget {
  const _LanguageDropdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(defaultTargetLanguageProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<TargetLanguage>(
          initialValue: current,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Learning',
          ),
          items: [
            for (final language in TargetLanguage.values)
              DropdownMenuItem<TargetLanguage>(
                value: language,
                child: Text(language.promptName),
              ),
          ],
          onChanged: (language) async {
            if (language == null) return;
            await applyLanguageChoice(
              context: context,
              ref: ref,
              controller: ref.read(conversationControllerProvider),
              picked: language,
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
          child: Text(
            current.endonym,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _CefrDropdown extends ConsumerWidget {
  const _CefrDropdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(defaultCefrLevelProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<CefrLevel>(
          initialValue: current,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Default level',
          ),
          items: [
            for (final level in CefrLevel.values)
              DropdownMenuItem<CefrLevel>(
                value: level,
                child: Text('${level.displayName} - ${level.description}'),
              ),
          ],
          onChanged: (level) async {
            if (level == null) return;
            await ref.read(defaultCefrLevelProvider.notifier).select(level);
            await ref.read(conversationControllerProvider)?.setCefrLevel(level);
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
          child: Text(
            current.guidance,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
