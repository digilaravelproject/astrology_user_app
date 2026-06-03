import 'package:astro_user/features/chat/domain/repositories/chat_repository_interface.dart';

class SendTextMessageUseCase {
  final ChatRepositoryInterface _repository;
  const SendTextMessageUseCase(this._repository);

  Future<int?> execute({required int sessionId, required String text}) {
    return _repository.sendTextMessage(sessionId: sessionId, text: text);
  }
}
