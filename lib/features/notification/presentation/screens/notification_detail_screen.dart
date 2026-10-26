import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:astro_user/features/notification/presentation/controllers/notification_controller.dart';
import 'package:astro_user/features/notification/data/models/notification_model.dart';

class NotificationDetailScreen extends StatefulWidget {
  final NotificationModel notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  final controller = Get.find<NotificationController>();

  @override
  void initState() {
    super.initState();
    // Mark as read when opening details if not already read
    if (!widget.notification.isRead) {
      controller.markAsRead(widget.notification.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AppText('Notification Details'.tr,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.trash, color: Colors.red, size: 20),
            tooltip: 'Delete Notification'.tr,
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Text('Delete Notification'.tr),
                  content: Text('Are you sure you want to delete this notification?'.tr),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel'.tr),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        controller.deleteNotification(widget.notification.id);
                        Get.back();
                      },
                      child: Text('Delete'.tr, style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Date Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightPink.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForType(widget.notification.type),
                    size: 24,
                    color: AppColors.deepPink,
                  ),
                ),
                const SizedBox(width: 12),
                AppText(
                  _formatTimestamp(widget.notification.createdAt),
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Title
            AppText(
              widget.notification.title ?? '',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.3,
            ),
            
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),
            
            // Message Body
            AppText(
              widget.notification.message ?? '',
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String? type) {
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

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      // More descriptive date formatting can be used here
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
    } catch (e) {
      return timestamp;
    }
  }
}
