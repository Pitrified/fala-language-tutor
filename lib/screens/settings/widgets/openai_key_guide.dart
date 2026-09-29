import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../build_info.dart';

/// Opens the guide to getting an OpenAI API key in the browser.
Future<void> openOpenAiKeyGuide() => launchUrl(
  Uri.parse(openAiKeyGuideUrl),
  mode: LaunchMode.externalApplication,
);

/// Link to the key guide under the key field on the Model page.
class OpenAiKeyGuideButton extends StatelessWidget {
  const OpenAiKeyGuideButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: openOpenAiKeyGuide,
      icon: const Icon(Icons.open_in_new, size: 18),
      label: const Text('How to get an OpenAI key'),
    );
  }
}

/// Settings list tile for the key guide, next to the Model entry.
class OpenAiKeyGuideTile extends StatelessWidget {
  const OpenAiKeyGuideTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: Icon(Icons.key_outlined),
      title: Text('How to get an OpenAI key'),
      trailing: Icon(Icons.open_in_new, size: 18),
      onTap: openOpenAiKeyGuide,
    );
  }
}
