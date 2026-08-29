import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:astro_user/core/services/foreground_task_service.dart';
import 'package:astro_user/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_user/features/call/presentation/pages/call_screen.dart';
import 'package:astro_user/features/call/presentation/controllers/call_controller.dart';
import 'package:astro_user/features/chat/presentation/controllers/chat_controller.dart';
import 'package:astro_user/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_user/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_user/features/live/presentation/pages/live_room_screen.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: DarwinInitializationSettings(),
        );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Tap handler: routes to the correct screen based on payload prefix
        final payload = response.payload;
        if (payload == null) return;

        debugPrint(
          '[LocalNotificationService] Tapped notification payload: $payload',
        );

        if (payload.startsWith('live_')) {
          // ── Live Stream notification ──
          final sessionIdStr = payload.replaceFirst('live_', '');
          final int? sessionId = int.tryParse(sessionIdStr);
          if (sessionId != null) {
            // Use addPostFrameCallback to ensure widget tree is ready
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.to(
                () => LiveRoomScreen(
                  sessionId: sessionId,
                  astrologerName: 'Astrologer',
                  astrologerImage: '',
                ),
              );
            });
          }
        } else if (payload.startsWith('call_')) {
          // ── Ongoing / Incoming Call notification ──
          bool isValidStatus = false;
          bool isVisible = false;

          if (Get.isRegistered<CallController>()) {
            final ctrl = Get.find<CallController>();
            isVisible = ctrl.isCallScreenVisible;
            final status = ctrl.status.value;
            isValidStatus =
                (status == 'ongoing' ||
                    status == 'ringing' ||
                    status == 'dialing' ||
                    status == 'waiting');
          }

          if (isValidStatus) {
            if (!isVisible) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.to(() => const CallScreen());
              });
            }
          } else {
            // It's a stale notification, cancel it
            debugPrint(
              '[LocalNotificationService] Stale call notification tapped, cancelling...',
            );
            final sessionIdStr = payload.replaceFirst('call_', '');
            final int? sessionId = int.tryParse(sessionIdStr);
            _notificationsPlugin.cancel(ACTIVE_CALL_NOTIFICATION_ID);
            if (sessionId != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.toNamed(
                  '/session-summary',
                  arguments: {'sessionId': sessionId},
                );
              });
            }
          }
        } else if (FloatingChatBubble.onTapCallback != null) {
          // ── Active Chat bubble tap ──
          WidgetsBinding.instance.addPostFrameCallback((_) {
            FloatingChatBubble.onTapCallback?.call();
          });
        } else {
          // ── Chat session notification (payload = sessionId as string) ──
          final int? sId = int.tryParse(payload);
          if (sId != null) {
            String astroName =
                FloatingChatBubble.name?.isNotEmpty == true
                    ? FloatingChatBubble.name!
                    : 'Astrologer';
            String astroStatus =
                FloatingChatBubble.chatStatus.value.isNotEmpty
                    ? FloatingChatBubble.chatStatus.value
                    : 'ongoing';

            WidgetsBinding.instance.addPostFrameCallback((_) {
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
            });
          }
        }
      },
    );

    // Pre-create notification channels explicitly

    final androidPlugin =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'call',
          'Incoming Call',
          description: 'Incoming audio/video call alerts',
          importance: Importance.max,
          sound: RawResourceAndroidNotificationSound('call_ringtone'),
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'chat',
          'Chat Message',
          description: 'New chat message alerts',
          importance: Importance.high,
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'chat_request',
          'Chat Requests',
          description: 'New chat consultation requests',
          importance: Importance.high,
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'call_request',
          'Call Requests',
          description: 'New call consultation requests',
          importance: Importance.high,
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'live_stream',
          'Live Stream Alerts',
          description: 'Astrologer live stream broadcast notifications',
          importance: Importance.high,
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'wallet',
          'Wallet & Orders',
          description: 'Payment, wallet, order updates',
          importance: Importance.defaultImportance,
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'general',
          'General Announcements',
          description: 'General/promotional alerts',
          importance: Importance.defaultImportance,
          playSound: true,
        ),
      );

      androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // ---------------------------------------------------------------------
  // Helper: Show a local notification (used for foreground FCM messages)
  // ---------------------------------------------------------------------
  static Future<void> showNotification({
    required String title,
    required String body,
    required String payload,
    required String channelId,
    int? notificationId,
    bool playSound = false,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId,
      channelDescription: 'Foreground push notification',
      importance: importance,
      priority: priority,
      playSound: playSound,
      icon: '@mipmap/ic_launcher',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: playSound,
      ),
    );

    await _notificationsPlugin.show(
      notificationId ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static const int ACTIVE_CHAT_NOTIFICATION_ID = 777777;
  static const int ACTIVE_CALL_NOTIFICATION_ID = 888888;

  static Future<void> cancelCallNotification() async {
    await _notificationsPlugin.cancel(ACTIVE_CALL_NOTIFICATION_ID);
  }

  static Future<void> cancelChatNotification() async {
    await _notificationsPlugin.cancel(ACTIVE_CHAT_NOTIFICATION_ID);
  }

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
