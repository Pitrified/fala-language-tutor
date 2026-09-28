import 'package:openai_dart/openai_dart.dart';

/// An OpenAI model offered in the model picker, with what sets it apart.
class OpenAiModelOption {
  const OpenAiModelOption({
    required this.id,
    required this.description,
    this.reasoningEffort,
  });

  /// Model id sent to the API.
  final String id;

  /// One line for the picker on how this model differs from the others.
  final String description;

  /// Sent with every request when set. `none` keeps a reasoning model from
  /// spending hidden, billed tokens before it answers, and lets it accept the
  /// app's temperature.
  final ReasoningEffort? reasoningEffort;
}

/// The models the tutor prompt was compared on (`docs/prompt-engineering.md`,
/// "Comparing prompts and models"). The first is the default.
const openAiModelOptions = <OpenAiModelOption>[
  OpenAiModelOption(
    id: 'gpt-5.4-nano',
    description:
        'Fastest to start replying, and the most natural at B2 to C2. '
        'Now and then misses a small error.',
    reasoningEffort: ReasoningEffort.none,
  ),
  OpenAiModelOption(
    id: 'gpt-6-luna',
    description:
        'The most precise corrections, at about a fifth of the cost. '
        'Slower to start replying, and its C1 reads closer to B2.',
    reasoningEffort: ReasoningEffort.none,
  ),
];

/// The option for [id], or null for a model id not in [openAiModelOptions].
OpenAiModelOption? openAiModelOption(String id) {
  for (final option in openAiModelOptions) {
    if (option.id == id) return option;
  }
  return null;
}
