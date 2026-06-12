import 'package:astro_user/features/history/data/repositories/history_repository.dart';
import 'package:astro_user/features/call/domain/models/call_session_model.dart';

class GetCallSessionsUseCase {
  final HistoryRepository _repository;

  GetCallSessionsUseCase(this._repository);

  Future<CallSessionListResponse> execute({int page = 1}) {
    return _repository.getCallSessions(page: page);
  }
}
