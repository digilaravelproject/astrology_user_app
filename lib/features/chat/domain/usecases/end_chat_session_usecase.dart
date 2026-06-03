import 'package:astro_user/features/chat/domain/entities/chat_session.dart';
import 'package:astro_user/features/chat/domain/repositories/chat_repository_interface.dart';

class EndChatSessionUseCase {
  final ChatRepositoryInterface _repository;
  const EndChatSessionUseCase(this._repository);

  Future<ChatSessionEntity?> execute(int sessionId) {
    return _repository.endChatSession(sessionId);
  }
}
