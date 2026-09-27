import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';

/// Red strip under the app bar while the selected engine needs setup (a key
/// that is not stored). Tapping it opens the Model page.
class ModelSetupBanner extends StatelessWidget {
  const ModelSetupBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.errorContainer,
      child: InkWell(
        onTap: () => context.push(AppRoutes.modelSettings),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.priority_high, color: scheme.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Model setup needed',
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onErrorContainer),
            ],
          ),
        ),
      ),
    );
  }
}
