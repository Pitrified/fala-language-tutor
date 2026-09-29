import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_provider.dart';
import '../../services/inference/engine_kind.dart';
import '../../services/inference/openai_models.dart';
import 'widgets/openai_key_guide.dart';

/// Model settings: the active inference engine, then the details of that
/// engine (the OpenAI key and model; the fake engine has none).
class ModelSettingsScreen extends StatelessWidget {
  const ModelSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Model')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [ModelSettingsBody()],
      ),
    );
  }
}

/// The engine picker and the selected engine's settings. On the Model page
/// and the first-run setup.
class ModelSettingsBody extends ConsumerWidget {
  const ModelSettingsBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedKind = ref.watch(selectedEngineKindProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inference engine',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _EngineDropdown(selected: selectedKind),
        // Engine-specific settings: only OpenAI has any; fake shows nothing.
        if (selectedKind == EngineKind.openai) ...[
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          Text('OpenAI', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const _OpenAiSection(),
        ],
      ],
    );
  }
}

class _EngineDropdown extends ConsumerWidget {
  const _EngineDropdown({required this.selected});

  final EngineKind selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButtonFormField<EngineKind>(
      initialValue: selected,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Active engine',
      ),
      items: EngineKind.values.map(_buildItem).toList(),
      onChanged: (kind) async {
        if (kind == null || !kind.isImplemented) return;
        final messenger = ScaffoldMessenger.of(context);
        await ref.read(selectedEngineKindProvider.notifier).select(kind);
        messenger.showSnackBar(
          SnackBar(content: Text('Engine set to ${kind.displayName}.')),
        );
      },
    );
  }

  DropdownMenuItem<EngineKind> _buildItem(EngineKind kind) {
    return DropdownMenuItem<EngineKind>(
      value: kind,
      enabled: kind.isImplemented,
      child: Text(kind.displayName),
    );
  }
}

class _OpenAiSection extends ConsumerStatefulWidget {
  const _OpenAiSection();

  @override
  ConsumerState<_OpenAiSection> createState() => _OpenAiSectionState();
}

class _OpenAiSectionState extends ConsumerState<_OpenAiSection> {
  final _keyController = TextEditingController();
  bool _hasStoredKey = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _refreshKeyStatus();
  }

  Future<void> _refreshKeyStatus() async {
    final store = ref.read(apiKeyStoreProvider);
    final has = await store.hasKey();
    if (!mounted) return;
    setState(() {
      _hasStoredKey = has;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final store = ref.read(apiKeyStoreProvider);
    final keyInput = _keyController.text.trim();
    if (keyInput.isNotEmpty) {
      await store.write(keyInput);
      _keyController.clear();
    }
    ref.invalidate(apiKeyPresentProvider);
    await _refreshKeyStatus();
    messenger.showSnackBar(const SnackBar(content: Text('Settings saved.')));
  }

  Future<void> _clearKey() async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(apiKeyStoreProvider).clear();
    _keyController.clear();
    ref.invalidate(apiKeyPresentProvider);
    await _refreshKeyStatus();
    messenger.showSnackBar(
      const SnackBar(content: Text('OpenAI key cleared.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _keyController,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'OpenAI API key',
            hintText: _loaded && _hasStoredKey
                ? 'Key stored. Enter to replace.'
                : 'sk-...',
            helperText: _loaded && _hasStoredKey
                ? 'A key is currently stored.'
                : 'No key stored yet.',
          ),
        ),
        const SizedBox(height: 12),
        const _ModelDropdown(),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton(onPressed: _save, child: const Text('Save')),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: _hasStoredKey ? _clearKey : null,
              child: const Text('Clear key'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const OpenAiKeyGuideButton(),
      ],
    );
  }
}

/// Picks the OpenAI model from [openAiModelOptions], saved on selection, with
/// the chosen model's description below. A stored id that is not offered any
/// more stays listed so the picker shows what is in use.
class _ModelDropdown extends ConsumerWidget {
  const _ModelDropdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(openaiModelProvider);
    final ids = [
      for (final option in openAiModelOptions) option.id,
      if (openAiModelOption(model) == null) model,
    ];
    return DropdownButtonFormField<String>(
      initialValue: model,
      isExpanded: true,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Model',
        helperText: openAiModelOption(model)?.description,
        helperMaxLines: 3,
      ),
      items: [
        for (final id in ids) DropdownMenuItem(value: id, child: Text(id)),
      ],
      onChanged: (id) async {
        if (id == null) return;
        await ref.read(openaiModelProvider.notifier).setModel(id);
      },
    );
  }
}
