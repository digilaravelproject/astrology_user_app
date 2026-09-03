import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';

class NotificationRepository {
  final ApiClient apiClient;

  NotificationRepository({required this.apiClient});

  Future<ResponseModel> getNotificationCount(int userId) async {
    return await apiClient.get(AppUrls.getNotificationCount(userId));
  }

  Future<ResponseModel> getNotifications(int userId, {int page = 1}) async {
    return await apiClient.get(AppUrls.getNotifications(userId, page: page));
  }

  Future<ResponseModel> getNotificationById(int id, int userId) async {
    return await apiClient.get(AppUrls.getNotificationById(id, userId));
  }

  Future<ResponseModel> markAsRead(int id, int userId) async {
    // The user provided PUT {{base_url_local}}/api/v1/user/notifications/1/mark-read?user_id=3
    return await apiClient.put(AppUrls.markNotificationRead(id, userId));
  }

  Future<ResponseModel> markAllAsRead(int userId) async {
    return await apiClient.post(AppUrls.markAllNotificationsRead(userId));
  }

  Future<ResponseModel> deleteNotification(int id, int userId) async {
    return await apiClient.delete(AppUrls.deleteNotification(id, userId));
  }

  Future<ResponseModel> deleteAllNotifications(int userId) async {
    return await apiClient.post(AppUrls.deleteAllNotifications(userId));
  }
}
