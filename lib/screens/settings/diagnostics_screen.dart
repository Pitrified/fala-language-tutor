import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/diagnostics_dump_provider.dart';
import '../../providers/diagnostics_provider.dart';
import '../onboarding/onboarding_screen.dart';

/// The diagnostics dump as plain text, with Copy and Clear, for pasting back
/// after a run on the phone, and a way into the first-run setup pages without
/// clearing the app's data.
class DiagnosticsScreen extends ConsumerWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dump = ref.watch(diagnosticsDumpProvider);
    final text = dump.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        actions: [
          IconButton(
            tooltip: 'Run first-run setup again',
            icon: const Icon(Icons.restart_alt),
            onPressed: () =>
                context.push(OnboardingScreen.routeFor(OnboardingStep.model)),
          ),
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await ref.read(diagnosticsLogProvider).clear();
              ref.invalidate(diagnosticsDumpProvider);
            },
          ),
          IconButton(
            tooltip: 'Copy',
            icon: const Icon(Icons.copy),
            onPressed: text == null
                ? null
                : () async {
                    await Clipboard.setData(ClipboardData(text: text));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Diagnostics copied')),
                    );
                  },
          ),
        ],
      ),
      body: text == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                text,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
    );
  }
}
