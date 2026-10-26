import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/core/constants/app_urls.dart';

class NotificationRepository {
  final ApiClient apiClient;

  NotificationRepository({required this.apiClient});

  Future<ResponseModel> getNotificationCount(int userId) async {
    return await apiClient.get(AppUrls.getNotificationCount(userId));
  }

  Future<ResponseModel> getNotifications(int userId, {int page = 1, int perPage = 20, String? filter}) async {
    return await apiClient.get(
      '${AppUrls.getNotifications(userId)}?page=$page&per_page=$perPage${filter != null ? '&filter=$filter' : ''}',
    );
  }

  Future<ResponseModel> getNotificationById(int id, int userId) async {
    return await apiClient.get(AppUrls.getNotificationById(id, userId));
  }

  Future<ResponseModel> markAsRead(int id, int userId) async {
    return await apiClient.put(AppUrls.markNotificationRead(id, userId));
  }

  Future<ResponseModel> markAllAsRead(int userId) async {
    return await apiClient.post(AppUrls.markAllNotificationsRead, data: {});
  }

  Future<ResponseModel> deleteNotification(int id, int userId) async {
    return await apiClient.delete(AppUrls.deleteNotification(id));
  }

  Future<ResponseModel> deleteAllNotifications(int userId) async {
    return await apiClient.post(AppUrls.deleteAllNotifications, data: {});
  }
}
