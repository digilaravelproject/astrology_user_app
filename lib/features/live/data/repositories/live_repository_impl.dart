import '../../../../core/services/network/response_model.dart';
import '../../domain/repositories/live_repository.dart';
import '../datasources/live_remote_data_source.dart';

class LiveRepositoryImpl implements LiveRepository {
  final LiveRemoteDataSource dataSource;

  LiveRepositoryImpl(this.dataSource);

  @override
  Future<ResponseModel> getActiveLiveSessions() async {
    return await dataSource.getActiveLiveSessions();
  }

  @override
  Future<ResponseModel> getLiveSessionDetail(int id) async {
    return await dataSource.getLiveSessionDetail(id);
  }

  @override
  Future<ResponseModel> joinLiveSession(int id) async {
    return await dataSource.joinLiveSession(id);
  }

  @override
  Future<ResponseModel> leaveLiveSession(int id) async {
    return await dataSource.leaveLiveSession(id);
  }

  @override
  Future<ResponseModel> sendLiveComment(int id, String message) async {
    return await dataSource.sendLiveComment(id, message);
  }

  @override
  Future<ResponseModel> sendSuperChat(int id, int giftId, String? message) async {
    return await dataSource.sendSuperChat(id, giftId, message);
  }

  @override
  Future<ResponseModel> getLiveComments(int id, {int perPage = 50}) async {
    return await dataSource.getLiveComments(id, perPage: perPage);
  }

  @override
  Future<ResponseModel> watchLiveSession(int id) async {
    return await dataSource.watchLiveSession(id);
  }
}

