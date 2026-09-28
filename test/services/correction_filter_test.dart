import 'package:fala/models/tutor_response.dart';
import 'package:fala/services/conversation/correction_filter.dart';
import 'package:flutter_test/flutter_test.dart';

TutorResponse _response(String content, List<CorrectionError> errors) =>
    TutorResponse(
      correction: CorrectionBlock(
        content: content,
        translation: 'translation',
        errors: errors,
      ),
      conversation: const ConversationBlock(content: 'Oi', translation: 'Hi'),
    );

const _real = CorrectionError(
  original: 'eu vai',
  corrected: 'eu fui',
  explanation: 'past tense',
);
const _noOp = CorrectionError(
  original: 'na praia',
  corrected: ' na praia',
  explanation: 'fine',
);

void main() {
  test('keeps a response whose errors all change something', () {
    final response = _response('eu fui na praia', [_real]);
    expect(dropNoOpCorrections(response, 'eu vai na praia'), response);
  });

  test('drops a no-op error and keeps the real one', () {
    final filtered = dropNoOpCorrections(
      _response('eu fui na praia', [_real, _noOp]),
      'eu vai na praia',
    );
    expect(filtered.correction.errors, [_real]);
    expect(filtered.correction.content, 'eu fui na praia');
  });

  test('clears a correction left empty that repeats the message', () {
    final filtered = dropNoOpCorrections(
      _response('eu fui na praia', [_noOp]),
      'eu fui na praia ',
    );
    expect(filtered.correction.errors, isEmpty);
    expect(filtered.correction.content, isEmpty);
    expect(filtered.correction.translation, isEmpty);
  });

  test('keeps a corrected sentence that differs even with no errors left', () {
    final filtered = dropNoOpCorrections(
      _response('Eu fui à praia.', [_noOp]),
      'eu fui na praia',
    );
    expect(filtered.correction.errors, isEmpty);
    expect(filtered.correction.content, 'Eu fui à praia.');
  });
}
