import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../providers/speech_provider.dart';
import 'widgets/openai_key_guide.dart';

/// The settings pages as a list of tiles: Language, Model and Diagnostics,
/// with the guide to getting an OpenAI key under Model.
///
/// Shown in the conversation drawer and on the Settings index, so both lead to
/// the same pages. A tap closes the drawer first when it sits in one, and stops
/// a reply being read aloud, since the learner is leaving the conversation.
class SettingsEntries extends ConsumerWidget {
  const SettingsEntries({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _entry(
          context,
          ref,
          icon: Icons.translate,
          title: 'Language',
          route: AppRoutes.languageSettings,
        ),
        _entry(
          context,
          ref,
          icon: Icons.memory,
          title: 'Model',
          route: AppRoutes.modelSettings,
        ),
        const OpenAiKeyGuideTile(),
        _entry(
          context,
          ref,
          icon: Icons.receipt_long,
          title: 'Diagnostics',
          route: AppRoutes.diagnostics,
        ),
      ],
    );
  }

  Widget _entry(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Scaffold.maybeOf(context)?.closeDrawer();
        unawaited(ref.read(speechProvider.notifier).stop());
        context.push(route);
      },
    );
  }
}
