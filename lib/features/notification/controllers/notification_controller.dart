import 'package:get/get.dart';
import '../domain/models/notification_model.dart';
import '../domain/repositories/notification_repository.dart';
import '../../auth/controllers/auth_controller.dart';

class NotificationController extends GetxController {
  final NotificationRepository repository;

  NotificationController({required this.repository});

  final unreadCount = 0.obs;
  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final selectedNotification = Rxn<NotificationModel>();

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    await fetchNotificationCount();
    await fetchNotifications();
  }

  int get _userId => Get.find<AuthController>().currentUser.value?.id ?? 0;

  Future<void> fetchNotificationCount() async {
    if (_userId == 0) {
      print('[NotificationController] Cannot fetch count: userId is 0');
      return;
    }
    try {
      final response = await repository.getNotificationCount(_userId);
      print('[NotificationController] Count Response body: ${response.body}');
      if (response.isSuccess && response.body != null) {
        // Since ResponseModel.fromJson already maps json['data'] to body
        final count =
            int.tryParse(response.body['unread']?.toString() ?? '0') ?? 0;
        unreadCount.value = count;
        print(
          '[NotificationController] Successfully updated unreadCount to: $count',
        );
      } else {
        print('[NotificationController] Request failed: ${response.message}');
      }
    } catch (e) {
      print('[NotificationController] Exception in fetchNotificationCount: $e');
    }
  }

  Future<void> fetchNotifications() async {
    if (_userId == 0) return;
    isLoading.value = true;
    try {
      final response = await repository.getNotifications(_userId);
      if (response.isSuccess && response.body != null) {
        // Since ResponseModel.fromJson already maps json['data'] to body
        final dynamic body = response.body;
        final List<dynamic> dataList =
            (body is List) ? body : (body?['notifications'] ?? body ?? []);
        notifications.assignAll(
          dataList.map((json) => NotificationModel.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNotificationDetail(int id) async {
    if (_userId == 0) return;
    isLoading.value = true;
    try {
      final response = await repository.getNotificationById(id, _userId);
      if (response.isSuccess && response.body != null) {
        selectedNotification.value = NotificationModel.fromJson(
          response.body['notification'] ?? response.body,
        );
      }
    } catch (e) {
      print('Error fetching notification detail: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(int id) async {
    if (_userId == 0) return;
    try {
      final response = await repository.markAsRead(id, _userId);
      if (response.isSuccess) {
        // Update local state
        final index = notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          final old = notifications[index];
          if (!old.isRead) {
            notifications[index] = NotificationModel(
              id: old.id,
              title: old.title,
              message: old.message,
              isRead: true,
              type: old.type,
              createdAt: old.createdAt,
            );
            notifications.refresh();
            if (unreadCount.value > 0) unreadCount.value--;
          }
        }
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
}
