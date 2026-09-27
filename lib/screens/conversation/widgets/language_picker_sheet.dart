import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/target_language.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/conversation/conversation_controller.dart';

/// What picking a language in the sheet should do to the current conversation.
enum LanguageSwitchAction {
  /// Nothing to do: dismissed, or the same language picked.
  none,

  /// The conversation has no messages, so its language can just change.
  switchInPlace,

  /// The conversation has messages in another language, so ask before starting
  /// a new one.
  confirmRestart,
}

/// Decide what a pick means, given the conversation's state.
///
/// Separate from the widget so the rule is testable without a modal sheet: the
/// language of a conversation with messages cannot change in place (see
/// `ConversationController.setLanguage`), and a no-op pick must not write
/// anything or prompt.
LanguageSwitchAction languageSwitchAction({
  required TargetLanguage? picked,
  required TargetLanguage current,
  required bool hasMessages,
}) {
  if (picked == null || picked == current) return LanguageSwitchAction.none;
  return hasMessages
      ? LanguageSwitchAction.confirmRestart
      : LanguageSwitchAction.switchInPlace;
}

/// Bottom sheet that lets the user pick a [TargetLanguage].
///
/// Returns the selected language, or `null` if the user dismissed the sheet
/// without picking. The active language is marked with a check.
///
/// Unlike the CEFR sheet this one can lead to a new conversation: a language
/// cannot change under an existing transcript (see `setLanguage`), so the caller
/// confirms with [showLanguageSwitchDialog] before restarting.
Future<TargetLanguage?> showLanguagePickerSheet(
  BuildContext context, {
  required TargetLanguage current,
}) {
  return showModalBottomSheet<TargetLanguage>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Language',
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
          ),
          for (final language in TargetLanguage.values)
            ListTile(
              title: Text(language.promptName),
              subtitle: Text(language.endonym),
              trailing: language == current ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(sheetContext).pop(language),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Ask whether to start a new conversation in [language].
///
/// Only needed when the current conversation already has messages: its history
/// is in the old language, so switching in place would give the tutor a
/// bilingual transcript to correct. Returns true when the user confirms.
Future<bool> showLanguageSwitchDialog(
  BuildContext context, {
  required TargetLanguage language,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Start over in ${language.displayName}?'),
      content: Text(
        'This conversation is in another language, so switching starts a new '
        'one. ${language.displayName} also becomes the default for future '
        'conversations either way.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Keep this one'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('New conversation'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Make [picked] the default language and apply it to [controller]'s open
/// conversation, from wherever the choice was made (the app bar chip or the
/// Settings screen).
///
/// The default always moves: the user said which language they want next. The
/// open conversation switches in place while it is empty; once it has messages
/// the user is asked before a new conversation starts in [picked], and keeps
/// the current one if they decline. With no open conversation, or no
/// controller yet, only the default changes.
Future<void> applyLanguageChoice({
  required BuildContext context,
  required WidgetRef ref,
  required ConversationController? controller,
  required TargetLanguage picked,
}) async {
  final conversation = controller?.currentConversation;
  final action = languageSwitchAction(
    picked: picked,
    current:
        TargetLanguageX.fromCode(conversation?.language) ??
        ref.read(defaultTargetLanguageProvider),
    hasMessages: conversation?.messages.isNotEmpty ?? false,
  );
  await ref.read(defaultTargetLanguageProvider.notifier).select(picked);
  if (controller == null || conversation == null) return;
  switch (action) {
    case LanguageSwitchAction.none:
      return;
    case LanguageSwitchAction.switchInPlace:
      await controller.setLanguage(picked);
    case LanguageSwitchAction.confirmRestart:
      if (!context.mounted) return;
      final confirmed = await showLanguageSwitchDialog(
        context,
        language: picked,
      );
      if (!confirmed) return;
      await controller.startConversation(
        language: picked,
        cefrLevel: ref.read(defaultCefrLevelProvider),
        topic: ref.read(defaultTopicProvider),
      );
  }
}
