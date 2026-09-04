import 'package:astro_user/core/services/network/response_model.dart';

abstract class LiveRepository {
  Future<ResponseModel> getActiveLiveSessions();
  Future<ResponseModel> getLiveSessionDetail(int id);
  Future<ResponseModel> joinLiveSession(int id);
  Future<ResponseModel> leaveLiveSession(int id);
  Future<ResponseModel> sendLiveComment(int id, String message);
  Future<ResponseModel> sendSuperChat(int id, int giftId, String? message);
  Future<ResponseModel> getLiveComments(int id, {int perPage = 50});
  Future<ResponseModel> watchLiveSession(int id);
}

