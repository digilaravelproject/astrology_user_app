import 'package:astro_user/features/chat/domain/repositories/chat_repository_interface.dart';

class MarkMessagesReadUseCase {
  final ChatRepositoryInterface _repository;
  const MarkMessagesReadUseCase(this._repository);

  Future<void> execute(int sessionId) {
    return _repository.markMessagesRead(sessionId);
  }
}
