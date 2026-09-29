import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../build_info.dart';

import '../../models/cefr_level.dart';
import '../../models/reply_length.dart';
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
        children: const [
          LanguageLevelSettings(),
          SizedBox(height: 24),
          Divider(),
          SizedBox(height: 8),
          ReplySettings(),
        ],
      ),
    );
  }
}

/// The language being learned and the CEFR level, with their explanations.
/// On the Language page and the first-run setup.
class LanguageLevelSettings extends StatelessWidget {
  const LanguageLevelSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}

/// Reply length, "say it better" and speech. On the Language page and the
/// first-run setup.
class ReplySettings extends StatelessWidget {
  const ReplySettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reply length', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'How long the tutor\'s replies are, from the next message.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        const _ReplyLengthDropdown(),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),
        const _SayBetterSwitch(),
        const SizedBox(height: 16),
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

/// The tutor's reply length, with what it asks for under the dropdown.
class _ReplyLengthDropdown extends ConsumerWidget {
  const _ReplyLengthDropdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(replyLengthProvider);
    return DropdownButtonFormField<ReplyLength>(
      initialValue: current,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Length',
        helperText: current.description,
      ),
      items: [
        for (final length in ReplyLength.values)
          DropdownMenuItem<ReplyLength>(
            value: length,
            child: Text(length.label),
          ),
      ],
      onChanged: (length) async {
        if (length == null) return;
        await ref.read(replyLengthProvider.notifier).select(length);
      },
    );
  }
}

/// "Say it better" with every reply, or on request with the button beside a
/// reply.
class _SayBetterSwitch extends ConsumerWidget {
  const _SayBetterSwitch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Say it better with every reply'),
      subtitle: const Text(
        'Your message rewritten a step richer, under each reply. Off: tap the '
        'sparkle beside a reply to ask for it.',
      ),
      value: ref.watch(sayBetterAutoProvider),
      onChanged: (on) => ref.read(sayBetterAutoProvider.notifier).set(on),
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
    final installed = ref.watch(speechEnginesProvider).value;
    final engines = [
      ...?installed,
      if (!(installed ?? const []).contains(sherpaEngine)) sherpaEngine,
    ];
    final chosen = ref.watch(speechEngineProvider);
    final current = engines.contains(chosen) ? chosen : null;
    final sherpaMissing =
        installed != null && !installed.contains(sherpaEngine);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String?>(
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
                child: Text(
                  engine == sherpaEngine && sherpaMissing
                      ? '${engineLabel(engine)} (not installed)'
                      : engineLabel(engine),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (engine) async {
            await ref.read(speechProvider.notifier).stop();
            await ref.read(speechEngineProvider.notifier).set(engine);
          },
        ),
        if (current == sherpaEngine && sherpaMissing) ...[
          const SizedBox(height: 8),
          Text(
            'Sherpa is a free voice app that runs on the phone. Install '
            'SherpaTTS and download a voice in it; until then the phone '
            'default reads the replies.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          TextButton(
            onPressed: () => launchUrl(
              Uri.parse(sherpaGuideUrl),
              mode: LaunchMode.externalApplication,
            ),
            child: const Text('How to install Sherpa'),
          ),
        ],
      ],
    );
  }
}

/// The voice for [language] on the chosen engine, or the engine's default.
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
            child: Text(voice.name, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (voice) async {
        await ref.read(speechProvider.notifier).stop();
        await ref.read(speechVoiceProvider.notifier).set(language, voice);
      },
    );
  }
}

/// A short name for the engines people are likely to have, the package name
/// for any other.
String engineLabel(String engine) => switch (engine) {
  'com.google.android.tts' => 'Google',
  sherpaEngine => 'Sherpa',
  _ => engine,
};

/// SherpaTTS's package name. Listed even when not installed, so the learner
/// can find out about it.
const String sherpaEngine = 'org.woheller69.ttsengine';
