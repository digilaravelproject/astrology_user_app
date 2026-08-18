import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:astro_user/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_user/features/call/presentation/pages/call_screen.dart';
import 'package:astro_user/features/call/presentation/controllers/call_controller.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Tap handler (navigates back or restores app state)
        if (response.payload != null) {
          if (response.payload!.startsWith('call_')) {
            bool isVisible = false;
            if (Get.isRegistered<CallController>()) {
              isVisible = Get.find<CallController>().isCallScreenVisible;
            }
            if (!isVisible) {
              Get.to(() => const CallScreen());
            }
          } else if (FloatingChatBubble.onTapCallback != null) {
            FloatingChatBubble.onTapCallback?.call();
          }
        }
      },
    );

    // Pre-create notification channels explicitly
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'astology_notifications',
          'System & General Notifications',
          description: 'General updates and system notifications',
          importance: Importance.max,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'active_chat_channel_v1',
          'Active Chats',
          description: 'Ongoing notification for active chat sessions',
          importance: Importance.max,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'active_call_channel_v1',
          'Active Calls',
          description: 'Ongoing notification for active audio/video call sessions',
          importance: Importance.max,
        ),
      );
      await androidPlugin.requestNotificationsPermission();
    }
  }

  static Future<void> showOngoingChatNotification({
    required int sessionId,
    required String title,
    required String body,
    int? startedAtMillis,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'active_chat_channel_v1',
      'Active Chats',
      channelDescription: 'Ongoing notification for active chat sessions',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: true,
      usesChronometer: startedAtMillis != null,
      when: startedAtMillis,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      sessionId,
      title,
      body,
      notificationDetails,
      payload: sessionId.toString(),
    );
  }

  static Future<void> cancelOngoingChatNotification(int sessionId) async {
    await _notificationsPlugin.cancel(sessionId);
  }

  static Future<void> showIncomingCallNotification({
    required int sessionId,
    required String title,
    required String body,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'incoming_call_channel_v1',
      'Incoming Calls',
      channelDescription: 'Alert for incoming calls',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: false,
      autoCancel: true,
      onlyAlertOnce: false,
      showWhen: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      sessionId + 200000,
      title,
      body,
      notificationDetails,
      payload: 'call_$sessionId',
    );
  }

  static Future<void> cancelIncomingCallNotification(int sessionId) async {
    await _notificationsPlugin.cancel(sessionId + 200000);
  }

  static Future<void> showOngoingCallNotification({
    required int sessionId,
    required String title,
    required String body,
    int? startedAtMillis,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'active_call_channel_v1',
      'Active Calls',
      channelDescription: 'Ongoing notification for active call sessions',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: true,
      usesChronometer: startedAtMillis != null,
      when: startedAtMillis,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      sessionId + 100000,
      title,
      body,
      notificationDetails,
      payload: 'call_$sessionId',
    );
  }

  static Future<void> cancelOngoingCallNotification(int sessionId) async {
    await _notificationsPlugin.cancel(sessionId + 100000);
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'astology_notifications',
      'System & General Notifications',
      channelDescription: 'General updates and system notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
