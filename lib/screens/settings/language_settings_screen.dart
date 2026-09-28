import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/cefr_level.dart';
import '../../models/target_language.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/speech_provider.dart';
import '../../services/speech/speech_service.dart';
import '../conversation/widgets/speak_button.dart';
import 'widgets/language_switch.dart';

/// Language settings: the language being learned and the CEFR level, which
/// apply to the open conversation as well as to new ones, and speech.
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
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          Text('Speech', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Replies are read with your phone\'s text-to-speech. The speaker '
            'next to a reply reads it again.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const _SpeechSection(),
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

/// The "Read replies aloud" switch, and a warning with an install button when
/// the phone has no voice for the language being learned.
///
/// Checks the voice again when the app returns to the foreground, which is how
/// the learner comes back from the install screen.
class _SpeechSection extends ConsumerStatefulWidget {
  const _SpeechSection();

  @override
  ConsumerState<_SpeechSection> createState() => _SpeechSectionState();
}

class _SpeechSectionState extends ConsumerState<_SpeechSection>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // An engine or voice may have been installed in Android settings.
      ref
        ..invalidate(voiceAvailableProvider)
        ..invalidate(speechEnginesProvider)
        ..invalidate(speechVoicesProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(defaultTargetLanguageProvider);
    final available = ref.watch(voiceAvailableProvider(language));
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Read replies aloud'),
          value: ref.watch(readRepliesAloudProvider),
          onChanged: (value) =>
              ref.read(readRepliesAloudProvider.notifier).set(value),
        ),
        const SizedBox(height: 8),
        const _EngineDropdown(),
        const SizedBox(height: 16),
        _VoiceDropdown(language),
        const SizedBox(height: 8),
        if (available.hasValue && !available.requireValue) ...[
          Text(
            'This phone has no ${language.displayName} voice yet, so replies '
            'stay silent.',
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => openVoiceInstall(context, ref),
            child: const Text('Install voice'),
          ),
        ],
      ],
    );
  }
}

/// The text-to-speech engine, from those installed, or the phone's default.
class _EngineDropdown extends ConsumerWidget {
  const _EngineDropdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engines = ref.watch(speechEnginesProvider).value ?? const <String>[];
    final chosen = ref.watch(speechEngineProvider);
    final current = engines.contains(chosen) ? chosen : null;
    return DropdownButtonFormField<String?>(
      key: ValueKey('engine/$current/${engines.length}'),
      initialValue: current,
      isExpanded: true,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Engine',
      ),
      items: [
        const DropdownMenuItem<String?>(child: Text('Phone default')),
        for (final engine in engines)
          DropdownMenuItem<String?>(
            value: engine,
            child: Text(engine, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (engine) async {
        await ref.read(speechProvider.notifier).stop();
        await ref.read(speechEngineProvider.notifier).set(engine);
      },
    );
  }
}

/// The voice for [language] on the chosen engine, or the engine's default.
/// Voices that send the text over the network are marked online.
class _VoiceDropdown extends ConsumerWidget {
  const _VoiceDropdown(this.language);

  final TargetLanguage language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voices =
        ref.watch(speechVoicesProvider(language)).value ??
        const <SpeechVoice>[];
    final chosen = ref.watch(speechVoiceProvider)[language];
    final current = voices.any((v) => v.name == chosen) ? chosen : null;
    return DropdownButtonFormField<String?>(
      key: ValueKey('voice/${language.code}/$current/${voices.length}'),
      initialValue: current,
      isExpanded: true,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Voice',
      ),
      items: [
        const DropdownMenuItem<String?>(child: Text('Engine default')),
        for (final voice in voices)
          DropdownMenuItem<String?>(
            value: voice.name,
            child: Text(
              voice.online ? '${voice.name} (online)' : voice.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (voice) async {
        await ref.read(speechProvider.notifier).stop();
        await ref.read(speechVoiceProvider.notifier).set(language, voice);
      },
    );
  }
}
