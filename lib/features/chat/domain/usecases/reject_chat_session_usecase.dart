import 'package:astro_user/features/chat/domain/repositories/i_chat_repository.dart';

class RejectChatSessionUseCase {
  final IChatRepository _repository;

  RejectChatSessionUseCase(this._repository);

  Future<void> execute(int sessionId) async {
    await _repository.rejectChatSession(sessionId);
  }
}
