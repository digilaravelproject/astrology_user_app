import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:astro_user/core/services/foreground_task_service.dart';
import 'package:astro_user/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_user/features/call/presentation/pages/call_screen.dart';
import 'package:astro_user/core/constants/app_constants.dart';
import 'package:astro_user/features/call/presentation/controllers/call_controller.dart';
import 'package:astro_user/features/chat/presentation/pages/chat_screen.dart';

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
          } else {
            final int? sId = int.tryParse(response.payload!);
            if (sId != null) {
              String astroName = FloatingChatBubble.name?.isNotEmpty == true
                  ? FloatingChatBubble.name!
                  : 'Astrologer';
              String astroStatus = FloatingChatBubble.chatStatus.value.isNotEmpty
                  ? FloatingChatBubble.chatStatus.value
                  : 'ongoing';

              FloatingChatBubble.dismiss(stopForegroundService: false);
              if (!Get.isRegistered<ChatController>()) {
                ChatBinding().dependencies();
              }
              Get.to(
                () => ChatScreen(
                  astrologerName: astroName,
                  astrologerImage: '',
                  sessionId: sId,
                  initialStatus: astroStatus,
                ),
                binding: ChatBinding(),
              );
            }
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
          'calls_channel',
          'Incoming Calls',
          description: 'Incoming Call Ringing (User & Astrologer)',
          importance: Importance.max,
          sound: RawResourceAndroidNotificationSound(AppConstants.callNotificationSound),
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'chats_channel',
          'Chat Messages & Requests',
          description: 'New Chat Requests and Chat Room messages',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound(AppConstants.chatNotificationSound),
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'session_channel',
          'Consultations & Billing',
          description: 'Session Lifecycle, Acceptance, Ending & Billing Notifications',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound(AppConstants.generalNotificationSound),
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'wallet_channel',
          'Wallet & Gifts',
          description: 'Wallet Top-Up, Gifts & Transactions',
          importance: Importance.defaultImportance,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'system_channel',
          'Account & System Alerts',
          description: 'Account status and system notifications',
          importance: Importance.defaultImportance,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'active_chat_channel_v1',
          'Active Chats',
          description: 'Ongoing notification for active chat sessions',
          importance: Importance.max,
          playSound: false,
          enableVibration: false,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'active_call_channel_v1',
          'Active Calls',
          description: 'Ongoing notification for active call sessions',
          importance: Importance.max,
          playSound: false,
          enableVibration: false,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'incoming_call_channel_v1',
          'Incoming Calls Alert',
          description: 'Alert for incoming call notifications',
          importance: Importance.max,
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'active_consultation_foreground_channel',
          'Active Consultation Service',
          description: 'Ongoing active call and chat consultation status',
          importance: Importance.max,
          playSound: false,
          enableVibration: false,
        ),
      );
      await androidPlugin.requestNotificationsPermission();
    }
  }

  static const int ACTIVE_CHAT_NOTIFICATION_ID = 777777;
  static const int ACTIVE_CALL_NOTIFICATION_ID = 888888;

  static Future<void> showOngoingChatNotification({
    required int sessionId,
    required String title,
    required String body,
    int? startedAtMillis,
  }) async {
    await _notificationsPlugin.cancel(ACTIVE_CHAT_NOTIFICATION_ID);
    await _notificationsPlugin.cancel(sessionId);
    await _notificationsPlugin.cancel(sessionId + 100);
    await _notificationsPlugin.cancel(sessionId + 50000);

    final int startTime = startedAtMillis ?? DateTime.now().millisecondsSinceEpoch;
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'active_consultation_foreground_channel_v3',
      'Active Consultation Service',
      channelDescription: 'Ongoing active call and chat consultation status',
      importance: Importance.max,
      priority: Priority.max,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: true,
      usesChronometer: true,
      when: startTime,
      category: AndroidNotificationCategory.call,
      visibility: NotificationVisibility.public,
      additionalFlags: Int32List.fromList([2, 64]),
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
      ACTIVE_CHAT_NOTIFICATION_ID,
      title,
      body,
      notificationDetails,
      payload: sessionId.toString(),
    );
  }

  static Future<void> cancelOngoingChatNotification(int? sessionId) async {
    await _notificationsPlugin.cancel(ACTIVE_CHAT_NOTIFICATION_ID);
    if (sessionId != null) {
      await _notificationsPlugin.cancel(sessionId);
      await _notificationsPlugin.cancel(sessionId + 100);
      await _notificationsPlugin.cancel(sessionId + 50000);
    }
    try {
      await ForegroundTaskService.stopService();
    } catch (_) {}
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
      iOS: const DarwinNotificationDetails(
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
    await _notificationsPlugin.cancel(ACTIVE_CALL_NOTIFICATION_ID);
    await _notificationsPlugin.cancel(sessionId + 100000);

    final int startTime = startedAtMillis ?? DateTime.now().millisecondsSinceEpoch;
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'active_consultation_foreground_channel_v3',
      'Active Consultation Service',
      channelDescription: 'Ongoing active call and chat consultation status',
      importance: Importance.max,
      priority: Priority.max,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: true,
      usesChronometer: true,
      when: startTime,
      category: AndroidNotificationCategory.call,
      visibility: NotificationVisibility.public,
      additionalFlags: Int32List.fromList([2, 64]),
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
      ACTIVE_CALL_NOTIFICATION_ID,
      title,
      body,
      notificationDetails,
      payload: 'call_$sessionId',
    );
  }

  static Future<void> cancelOngoingCallNotification(int? sessionId) async {
    await _notificationsPlugin.cancel(ACTIVE_CALL_NOTIFICATION_ID);
    if (sessionId != null) {
      await _notificationsPlugin.cancel(sessionId);
      await _notificationsPlugin.cancel(sessionId + 100000);
      await _notificationsPlugin.cancel(sessionId + 200000);
    }
    try {
      await ForegroundTaskService.stopService();
    } catch (_) {}
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? notificationType,
  }) async {
    String channelId = 'session_channel';
    String soundName = AppConstants.generalNotificationSound;

    if (notificationType == 'call' || notificationType == 'CALL_ACCEPTED' || notificationType == 'CALL_REQUEST') {
      channelId = 'calls_channel';
      soundName = AppConstants.callNotificationSound;
    } else if (notificationType == 'chat' || notificationType == 'CHAT_REQUEST' || notificationType == 'MessageSent') {
      channelId = 'chats_channel';
      soundName = AppConstants.chatNotificationSound;
    }

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == 'calls_channel'
          ? 'Incoming Calls'
          : (channelId == 'chats_channel' ? 'Chat Messages & Requests' : 'Consultations & Billing'),
      channelDescription: 'System and real-time notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(soundName),
      playSound: true,
      showWhen: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: '$soundName.caf',
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
