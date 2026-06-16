import '../../../../core/services/network/response_model.dart';
import '../repositories/live_repository.dart';

class GetActiveLiveSessionsUseCase {
  final LiveRepository repository;
  GetActiveLiveSessionsUseCase(this.repository);

  Future<ResponseModel> call() async {
    return await repository.getActiveLiveSessions();
  }
}

class GetLiveSessionDetailUseCase {
  final LiveRepository repository;
  GetLiveSessionDetailUseCase(this.repository);

  Future<ResponseModel> call(int id) async {
    return await repository.getLiveSessionDetail(id);
  }
}

class JoinLiveSessionUseCase {
  final LiveRepository repository;
  JoinLiveSessionUseCase(this.repository);

  Future<ResponseModel> call(int id) async {
    return await repository.joinLiveSession(id);
  }
}

class LeaveLiveSessionUseCase {
  final LiveRepository repository;
  LeaveLiveSessionUseCase(this.repository);

  Future<ResponseModel> call(int id) async {
    return await repository.leaveLiveSession(id);
  }
}

class SendLiveCommentUseCase {
  final LiveRepository repository;
  SendLiveCommentUseCase(this.repository);

  Future<ResponseModel> call(int id, String message) async {
    return await repository.sendLiveComment(id, message);
  }
}

class SendSuperChatUseCase {
  final LiveRepository repository;
  SendSuperChatUseCase(this.repository);

  Future<ResponseModel> call(int id, int giftId, String? message) async {
    return await repository.sendSuperChat(id, giftId, message);
  }
}

class GetLiveCommentsUseCase {
  final LiveRepository repository;
  GetLiveCommentsUseCase(this.repository);

  Future<ResponseModel> call(int id, {int perPage = 50}) async {
    return await repository.getLiveComments(id, perPage: perPage);
  }
}

class WatchLiveSessionUseCase {
  final LiveRepository repository;
  WatchLiveSessionUseCase(this.repository);

  Future<ResponseModel> call(int id) async {
    return await repository.watchLiveSession(id);
  }
}

