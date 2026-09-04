import 'package:astro_user/features/chat/domain/repositories/i_chat_repository.dart';

class CancelChatSessionUseCase {
  final IChatRepository _repository;

  CancelChatSessionUseCase(this._repository);

  Future<void> execute(int sessionId) async {
    await _repository.cancelChatSession(sessionId);
  }
}
