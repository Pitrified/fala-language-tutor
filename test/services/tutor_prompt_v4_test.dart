import 'package:fala/services/prompt/prompt_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('v4 builds from the shipped reply style and splits in two', () async {
    final manager = PromptManager();
    final style = await manager.replyStyle();
    final level = style.replyLevel('B1');
    final prompt = await manager.buildPrompt(
      name: 'tutor_response',
      version: 4,
      variables: {
        'target_language': 'Portuguese (Brazilian)',
        'explanation_language': 'English',
        'cefr_level': 'B1',
        'reply_level': level,
        'level_guide': style.levelGuide(level),
        'reply_samples': style.samples('pt-BR', level),
        'length_rule': style.lengthRule('normal'),
        'topic': '',
        'user_message': 'Oi',
        'conversation_history': 'User: Oi',
      },
    );
    final parts = PromptManager.split(prompt);
    expect(parts.developer, startsWith('# Identity'));
    expect(parts.developer, contains('up to 15 words'));
    expect(parts.developer, contains('Replies at B1 level'));
    expect(parts.user, contains('<learner_message>\nOi\n</learner_message>'));
  });

  test('a prompt without the user line is all user message', () {
    final parts = PromptManager.split('just this');
    expect(parts.developer, isNull);
    expect(parts.user, 'just this');
  });
}
