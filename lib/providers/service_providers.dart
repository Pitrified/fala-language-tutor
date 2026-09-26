import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/persistence/conversation_repository.dart';
import '../services/prompt/prompt_manager.dart';

/// Provider for the conversation repository.
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepository();
});

/// Provider for the prompt manager.
final promptManagerProvider = Provider<PromptManager>((ref) {
  return PromptManager();
});
