import 'package:astro_user/features/history/data/repositories/history_repository.dart';
import 'package:astro_user/features/history/domain/models/chat_session_model.dart';

class GetChatSessionsUseCase {
  final HistoryRepository _repository;

  GetChatSessionsUseCase(this._repository);

  Future<ChatSessionListResponse> execute({int page = 1}) {
    return _repository.getChatSessions(page: page);
  }
}
