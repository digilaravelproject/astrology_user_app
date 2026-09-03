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

  // Pagination
  int _currentPage = 1;
  bool _hasMore = true;
  final isFetchingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    await fetchNotificationCount();
    await fetchNotifications(refresh: true);
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

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (_userId == 0) return;
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      isLoading.value = true;
    } else {
      if (!_hasMore || isFetchingMore.value) return;
      isFetchingMore.value = true;
    }

    try {
      final response = await repository.getNotifications(
        _userId,
        page: _currentPage,
      );
      if (response.isSuccess && response.body != null) {
        final dynamic body = response.body;
        final List<dynamic> dataList =
            (body is List) ? body : (body?['notifications'] ?? body ?? []);

        final newItems =
            dataList.map((json) => NotificationModel.fromJson(json)).toList();

        if (refresh) {
          notifications.assignAll(newItems);
        } else {
          notifications.addAll(newItems);
        }

        // Handle pagination meta
        if (body is Map<String, dynamic> && body.containsKey('pagination')) {
          final pagination = body['pagination'];
          _hasMore = pagination['has_more'] ?? false;
          if (_hasMore) {
            _currentPage++;
          }
        } else {
          // If no pagination info, assume no more
          _hasMore = false;
        }
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
      isFetchingMore.value = false;
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

  Future<void> markAllAsRead() async {
    if (_userId == 0) return;
    try {
      final response = await repository.markAllAsRead(_userId);
      if (response.isSuccess) {
        for (var i = 0; i < notifications.length; i++) {
          final old = notifications[i];
          if (!old.isRead) {
            notifications[i] = NotificationModel(
              id: old.id,
              title: old.title,
              message: old.message,
              isRead: true,
              type: old.type,
              createdAt: old.createdAt,
            );
          }
        }
        notifications.refresh();
        unreadCount.value = 0;
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(int id) async {
    if (_userId == 0) return;
    try {
      final response = await repository.deleteNotification(id, _userId);
      if (response.isSuccess) {
        final index = notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          final n = notifications[index];
          notifications.removeAt(index);
          if (!n.isRead && unreadCount.value > 0) {
            unreadCount.value--;
          }
        }
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Future<void> deleteAllNotifications() async {
    if (_userId == 0) return;
    try {
      final response = await repository.deleteAllNotifications(_userId);
      if (response.isSuccess) {
        notifications.clear();
        unreadCount.value = 0;
      }
    } catch (e) {
      print('Error deleting all notifications: $e');
    }
  }
}
