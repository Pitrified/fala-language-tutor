import '../../models/tutor_response.dart';

/// Removes corrections that change nothing from a finished [response] to
/// [userMessage].
///
/// Some models list a correct phrase as an error, with `corrected` equal to
/// `original` and an explanation saying it is fine
/// (`docs/prompt-engineering.md`, Models). Those entries are dropped. When
/// none is left and the corrected sentence is the learner's own message, the
/// correction is cleared, which the reply shows as "no errors".
TutorResponse dropNoOpCorrections(TutorResponse response, String userMessage) {
  final correction = response.correction;
  final errors = correction.errors
      .where((e) => e.original.trim() != e.corrected.trim())
      .toList();
  if (errors.length == correction.errors.length) return response;
  final repeatsMessage = correction.content.trim() == userMessage.trim();
  return response.copyWith(
    correction: errors.isEmpty && repeatsMessage
        ? const CorrectionBlock(content: '', translation: '', errors: [])
        : correction.copyWith(errors: errors),
  );
}
