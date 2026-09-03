import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/notification_controller.dart';
import '../domain/models/notification_model.dart';
import 'notification_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationController controller = Get.find<NotificationController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchNotifications(refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.fetchNotifications(refresh: false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AppText(
          AppStrings.notifications,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.tick_circle, color: AppColors.deepPink),
            tooltip: "Mark all as read",
            onPressed: () => controller.markAllAsRead(),
          ),
          IconButton(
            icon: const Icon(Iconsax.trash, color: Colors.redAccent),
            tooltip: "Delete all",
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const AppText('Clear Notifications'),
                  content: const AppText('Are you sure you want to delete all notifications?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const AppText('Cancel', color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        controller.deleteAllNotifications();
                      },
                      child: const AppText('Delete All', color: Colors.redAccent),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (controller.notifications.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNotifications(refresh: true),
          color: AppColors.primaryColor,
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: controller.notifications.length + (controller.isFetchingMore.value ? 1 : 0),
            separatorBuilder:
                (context, index) =>
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
            itemBuilder: (context, index) {
              if (index == controller.notifications.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primaryColor),
                  ),
                );
              }
              final notification = controller.notifications[index];
              return Dismissible(
                key: Key(notification.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  color: Colors.redAccent,
                  child: const Icon(Iconsax.trash, color: Colors.white),
                ),
                onDismissed: (direction) {
                  controller.deleteNotification(notification.id);
                },
                child: GestureDetector(
                  onTap:
                      () => Get.to(
                        () =>
                            NotificationDetailScreen(notification: notification),
                      ),
                  child: _buildNotificationItem(notification),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: AppColors.lightPink,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.notification_bing,
              size: 50,
              color: AppColors.deepPink,
            ),
          ),
          const SizedBox(height: 20),
          AppText(
            AppStrings.noNotifications,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: AppText(
              AppStrings.noNotificationsSubtitle,
              fontSize: 14,
              color: Colors.black54,
              textAlign: TextAlign.center,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    bool isRead = notification.isRead;

    IconData getIconForType(String? type) {
      switch (type?.toLowerCase()) {
        case 'live':
          return Iconsax.video_copy;
        case 'horoscope':
          return Iconsax.moon_copy;
        case 'offer':
          return Iconsax.discount_shape_copy;
        case 'order':
          return Iconsax.bag_2_copy;
        default:
          return Iconsax.notification_bing_copy;
      }
    }

    return Container(
      color: isRead ? Colors.white : AppColors.lightPink.withOpacity(0.3),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isRead ? const Color(0xFFF5F5F5) : AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isRead
                        ? Colors.transparent
                        : AppColors.deepPink.withOpacity(0.2),
              ),
            ),
            child: Icon(
              getIconForType(notification.type),
              size: 20,
              color: isRead ? Colors.grey : AppColors.deepPink,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText(
                        notification.title ?? '',
                        fontSize: 15,
                        fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    AppText(
                      _formatTimestamp(notification.createdAt),
                      fontSize: 11,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                AppText(
                  notification.message ?? '',
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.4,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isRead)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 20),
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.deepPink,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      // Very simple time ago logic
      Duration diff = DateTime.now().difference(dateTime);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (e) {
      return timestamp;
    }
  }
}
