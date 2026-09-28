import 'package:fala/models/target_language.dart';
import 'package:fala/services/conversation/conversation_controller.dart';
import 'package:fala/services/prompt/prompt_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// Checks the real shipped template against the real variable set, rather than
/// a fixture that could drift from either. The variables are the ones
/// `ConversationController.sendMessage` passes; if that list and the template
/// stop agreeing, `buildPrompt` throws and this test says which variable.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<Map<String, String>> variablesFor(TargetLanguage language) async {
    final style = await PromptManager().replyStyle();
    return {
      'target_language': language.promptName,
      'explanation_language': ConversationController.explanationLanguage,
      'cefr_level': 'A1',
      'reply_level': style.replyLevel('A1'),
      'level_guide': style.levelGuide('A1'),
      'reply_samples': style.samples(language.code, 'A1'),
      'length_rule': style.lengthRule('normal'),
      'topic': '',
      'user_message': 'Oi',
      'conversation_history': '',
    };
  }

  test(
    'the latest template resolves with the controller variable set',
    () async {
      final prompt = await PromptManager().buildPrompt(
        name: 'tutor_response',
        variables: await variablesFor(TargetLanguage.ptBr),
      );

      expect(prompt, contains('tutor. The learner is at A1 level'));
      expect(prompt, contains('conversation partner and tutor'));
      expect(prompt, contains('Portuguese (Brazilian)'));
      expect(prompt, contains('its English translation'));
      expect(prompt, isNot(contains('{{')));
    },
  );

  test('the same template names any other language', () async {
    final prompt = await PromptManager().buildPrompt(
      name: 'tutor_response',
      variables: await variablesFor(TargetLanguage.deDe),
    );

    expect(prompt, contains('friendly German conversation partner'));
    expect(prompt, contains('always in German'));
    expect(prompt, isNot(contains('Portuguese')));
  });
}
