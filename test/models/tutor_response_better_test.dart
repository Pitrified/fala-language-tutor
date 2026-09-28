import 'package:fala/models/tutor_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a reply saved before "say it better" parses with it empty', () {
    final response = TutorResponse.fromJson({
      'correction': {'content': '', 'translation': '', 'errors': <dynamic>[]},
      'conversation': {'content': 'Oi', 'translation': 'Hi'},
    });
    expect(response.better.content, isEmpty);
    expect(response.better.translation, isEmpty);
  });

  test('"say it better" round-trips through JSON', () {
    final response = TutorResponse.fromJson({
      'correction': {'content': '', 'translation': '', 'errors': <dynamic>[]},
      'conversation': {'content': 'Oi', 'translation': 'Hi'},
      'better': {'content': 'Olá!', 'translation': 'Hello!'},
    });
    expect(TutorResponse.fromJson(response.toJson()), response);
  });
}
