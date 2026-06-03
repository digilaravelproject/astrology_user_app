import 'package:astro_user/features/chat/domain/entities/chat_message.dart';
import 'package:astro_user/features/chat/domain/repositories/chat_repository_interface.dart';

class LoadChatHistoryUseCase {
  final ChatRepositoryInterface _repository;
  const LoadChatHistoryUseCase(this._repository);

  Future<({List<ChatMessageEntity> messages, String? startedAt})> execute({
    required int sessionId,
    required int currentUserId,
  }) {
    return _repository.getChatHistory(
      sessionId: sessionId,
      currentUserId: currentUserId,
    );
  }
}
