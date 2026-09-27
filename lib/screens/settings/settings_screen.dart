import 'package:flutter/material.dart';

import 'settings_entries.dart';

/// Settings index: the same entries the conversation drawer lists, for the
/// screens without a drawer (the welcome screen's gear).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(children: const [SettingsEntries()]),
    );
  }
}
