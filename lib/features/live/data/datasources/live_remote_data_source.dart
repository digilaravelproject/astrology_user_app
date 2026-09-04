import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/services/network/response_model.dart';

class LiveRemoteDataSource {
  final ApiClient _apiClient;

  LiveRemoteDataSource(this._apiClient);

  Future<ResponseModel> getActiveLiveSessions() async {
    print('[LIVE_DS] Getting active live sessions');
    final result = await _apiClient.get(AppUrls.activeLiveSessions);
    return result;
  }

  Future<ResponseModel> getLiveSessionDetail(int id) async {
    print('[LIVE_DS] Getting live session detail: $id');
    final result = await _apiClient.get(AppUrls.liveSessionDetail(id));
    return result;
  }

  Future<ResponseModel> joinLiveSession(int id) async {
    print('[LIVE_DS] Joining live session: $id');
    final result = await _apiClient.post(AppUrls.joinLiveSession(id), data: {});
    return result;
  }

  Future<ResponseModel> leaveLiveSession(int id) async {
    print('[LIVE_DS] Leaving live session: $id');
    final result = await _apiClient.post(AppUrls.leaveLiveSession(id), data: {});
    return result;
  }

  Future<ResponseModel> sendLiveComment(int id, String message) async {
    print('[LIVE_DS] Sending live comment to session $id: $message');
    final result = await _apiClient.post(AppUrls.sendLiveComment(id), data: {'message': message});
    return result;
  }

  Future<ResponseModel> sendSuperChat(int id, int giftId, String? message) async {
    print('[LIVE_DS] Sending super chat: session $id, gift $giftId, message: $message');
    final Map<String, dynamic> data = {'gift_id': giftId};
    if (message != null && message.isNotEmpty) {
      data['message'] = message;
    }
    final result = await _apiClient.post(AppUrls.sendSuperChat(id), data: data);
    return result;
  }

  Future<ResponseModel> getLiveComments(int id, {int perPage = 50}) async {
    print('[LIVE_DS] Getting live comments for session $id, perPage: $perPage');
    final result = await _apiClient.get('${AppUrls.getLiveComments(id)}?per_page=$perPage');
    return result;
  }

  Future<ResponseModel> watchLiveSession(int id) async {
    print('[LIVE_DS] Watching live session: $id');
    final result = await _apiClient.post(AppUrls.watchLiveSession(id), data: {});
    return result;
  }
}

