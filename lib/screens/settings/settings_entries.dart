import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';

/// The settings pages as a list of tiles: Language and Model.
///
/// Shown in the conversation drawer and on the Settings index, so both lead to
/// the same pages. A tap closes the drawer first when it sits in one.
class SettingsEntries extends StatelessWidget {
  const SettingsEntries({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _entry(
          context,
          icon: Icons.translate,
          title: 'Language',
          route: AppRoutes.languageSettings,
        ),
        _entry(
          context,
          icon: Icons.memory,
          title: 'Model',
          route: AppRoutes.modelSettings,
        ),
      ],
    );
  }

  Widget _entry(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Scaffold.maybeOf(context)?.closeDrawer();
        context.push(route);
      },
    );
  }
}
