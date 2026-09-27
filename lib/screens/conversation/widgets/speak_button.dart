import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/target_language.dart';
import '../../../providers/speech_provider.dart';

/// Speaker icon beside a tutor reply: reads [text] in [language], and while
/// that reply plays, shows a stop icon that stops it.
///
/// With no voice installed for [language], a tap explains that instead and
/// offers the install screen.
class SpeakButton extends ConsumerWidget {
  const SpeakButton({
    super.key,
    required this.messageId,
    required this.text,
    required this.language,
  });

  /// Id of the message this button reads.
  final String messageId;

  /// The reply text, before [speakableText] cleans it.
  final String text;

  /// The conversation's language, which picks the voice.
  final TargetLanguage language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playing = ref.watch(speechProvider) == messageId;
    return IconButton(
      visualDensity: VisualDensity.compact,
      tooltip: playing ? 'Stop reading' : 'Read aloud',
      icon: Icon(
        playing ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
        size: 20,
      ),
      onPressed: () async {
        final speech = ref.read(speechProvider.notifier);
        if (playing) {
          await speech.stop();
          return;
        }
        final available = await ref
            .read(speechServiceProvider)
            .isVoiceAvailable(language);
        if (!context.mounted) return;
        if (!available) {
          await showMissingVoiceDialog(context, ref, language);
          return;
        }
        await speech.play(messageId: messageId, text: text, language: language);
      },
    );
  }
}

/// Tell the learner the phone has no voice for [language], and offer the
/// system screen that installs one.
Future<void> showMissingVoiceDialog(
  BuildContext context,
  WidgetRef ref,
  TargetLanguage language,
) async {
  final install = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('No ${language.displayName} voice'),
      content: Text(
        'fala reads replies with your phone\'s text-to-speech, which has no '
        '${language.displayName} voice installed yet. Install one, then tap '
        'the speaker again.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Install voice'),
        ),
      ],
    ),
  );
  if (install != true || !context.mounted) return;
  await openVoiceInstall(context, ref);
}

/// Open the voice install screen, or say where to find it when the phone has
/// none to open.
Future<void> openVoiceInstall(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final opened = await ref.read(speechServiceProvider).openVoiceInstall();
  if (opened) return;
  messenger.showSnackBar(
    const SnackBar(
      content: Text(
        'Add a voice in Android Settings, under text-to-speech output.',
      ),
    ),
  );
}
