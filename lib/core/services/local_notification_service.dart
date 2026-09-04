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
import 'package:astro_user/routes/app_routes.dart';

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
        // Tap handler: routes to the correct screen based on payload prefix
        final payload = response.payload;
        if (payload == null) return;

        debugPrint('[LocalNotificationService] Tapped notification payload: $payload');

        if (payload.startsWith('live_')) {
          // ── Live Stream notification ──
          final sessionIdStr = payload.replaceFirst('live_', '');
          final int? sessionId = int.tryParse(sessionIdStr);
          if (sessionId != null) {
            // Use addPostFrameCallback to ensure widget tree is ready
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.to(() => LiveRoomScreen(
                sessionId: sessionId,
                astrologerName: 'Astrologer',
                astrologerImage: '',
              ));
            });
          }
        } else if (payload.startsWith('call_')) {
          // ── Ongoing / Incoming Call notification ──
          bool isVisible = false;
          if (Get.isRegistered<CallController>()) {
            isVisible = Get.find<CallController>().isCallScreenVisible;
          }
          if (!isVisible) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.toNamed(AppRoutes.callScreen);
            });
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
            String astroName = FloatingChatBubble.name?.isNotEmpty == true
                ? FloatingChatBubble.name!
                : 'Astrologer';
            String astroStatus = FloatingChatBubble.chatStatus.value.isNotEmpty
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
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // --- FCM Spec Channels ---
      // call_channel: Incoming Calls (max importance, sound OFF)
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'call_channel_v2',
          'Incoming Calls',
          description: 'Incoming Audio/Video Call wake-up alert',
          importance: Importance.max,
          playSound: false,
        ),
      );
      // chat_channel: Chat messages (sound controlled per message via play_sound)
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'chat_channel_v2',
          'Chat Messages & Requests',
          description: 'Regular chat messages (silent) and new chat session requests (audible)',
          importance: Importance.high,
          playSound: false, // Channel allows sound; silenced per-message when play_sound==0
        ),
      );
      // live_session_channel: Live stream broadcasts (sound OFF)
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'live_session_channel_v2',
          'Live Session Alerts',
          description: 'Astrologer live stream broadcast notifications',
          importance: Importance.high,
          playSound: false,
        ),
      );
      // astology_notifications: General / promo / system (default importance)
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'astology_notifications_v2',
          'General Announcements',
          description: 'Promotional messages, wallet updates and system alerts',
          importance: Importance.defaultImportance,
          playSound: false,
        ),
      );

      // --- Legacy / Ongoing Service Channels (kept for backward compat) ---
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'calls_channel',
          'Incoming Calls (Legacy)',
          description: 'Incoming Call Ringing (User & Astrologer)',
          importance: Importance.max,
          playSound: false,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'chats_channel',
          'Chat Messages & Requests (Legacy)',
          description: 'New Chat Requests and Chat Room messages',
          importance: Importance.high,
          playSound: false,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'session_channel',
          'Consultations & Billing',
          description: 'Session Lifecycle, Acceptance, Ending & Billing Notifications',
          importance: Importance.high,
          playSound: false,
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
          playSound: false,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'active_consultation_foreground_channel_v4',
          'Active Consultation Service',
          description: 'Ongoing active call and chat consultation status',
          importance: Importance.max,
          playSound: false,
          enableVibration: false,
        ),
      );
      androidPlugin.requestNotificationsPermission();
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

    final bool isAccepted = startedAtMillis != null;
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'active_consultation_foreground_channel_v4',
      'Active Consultation Service',
      channelDescription: 'Ongoing active call and chat consultation status',
      icon: '@mipmap/ic_launcher',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: isAccepted,
      usesChronometer: isAccepted,
      when: isAccepted ? startedAtMillis : null,
      subText: isAccepted ? 'Ongoing Session' : 'Ringing...',
      category: AndroidNotificationCategory.service,
      visibility: NotificationVisibility.public,
      audioAttributesUsage: AudioAttributesUsage.notification,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _notificationsPlugin.show(
        ACTIVE_CHAT_NOTIFICATION_ID,
        title,
        body,
        notificationDetails,
        payload: sessionId.toString(),
      );
    } catch (_) {}
    try {
      await ForegroundTaskService.startActiveSessionNotification(
        title: title,
        type: 'Chat',
      );
    } catch (e) {
      debugPrint("ForegroundTaskService start ignored due to OS policy: $e");
    }
  }

  static Future<void> cancelOngoingChatNotification(int? sessionId) async {
    try {
      await _notificationsPlugin.cancel(ACTIVE_CHAT_NOTIFICATION_ID);
      if (sessionId != null) {
        await _notificationsPlugin.cancel(sessionId);
        await _notificationsPlugin.cancel(sessionId + 100);
        await _notificationsPlugin.cancel(sessionId + 50000);
      }
    } catch (e) {
      debugPrint("LocalNotificationService cancel exception (handled): $e");
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
      icon: '@mipmap/ic_launcher',
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
      title.tr,
      body.tr,
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
    final int startTime = startedAtMillis ?? DateTime.now().millisecondsSinceEpoch;
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'active_consultation_foreground_channel_v3',
      'Active Consultation Service',
      channelDescription: 'Ongoing active call and chat consultation status',
      icon: '@mipmap/ic_launcher',
      importance: Importance.low,
      priority: Priority.low,
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
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      ),
    );

    try {
      await _notificationsPlugin.show(
        ACTIVE_CALL_NOTIFICATION_ID,
        title,
        body,
        notificationDetails,
        payload: 'call_$sessionId',
      );
    } catch (_) {}
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

  /// Shows a general push notification.
  /// [playSound] — read from FCM data['play_sound']: '1' = audible, '0' = silent.
  /// Channel and sound behaviour are derived from [notificationType] per the FCM spec.
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? notificationType,
    bool playSound = false, // driven by FCM data['play_sound']
  }) async {
    // ── Channel mapping (matches FCM spec) ──────────────────────────────────
    // chat           → chat_channel   (silent by default)
    // session_request / CHAT_REQUEST  → chat_channel   (audible)
    // call / CALL_REQUEST             → call_channel   (audible)
    // live_stream / live              → live_session_channel (audible)
    // promo / system / default        → astology_notifications (audible)
    String channelId;
    String channelName;

    switch (notificationType) {
      case 'call':
      case 'CALL_REQUEST':
      case 'CALL_ACCEPTED':
        channelId = 'call_channel_v2';
        channelName = 'Incoming Calls';
        break;
      case 'chat':
      case 'CHAT_REQUEST':
      case 'session_request':
      case 'MessageSent':
        channelId = 'chat_channel_v2';
        channelName = 'Chat Messages & Requests';
        break;
      case 'live_stream':
      case 'live':
      case 'live_session':
        channelId = 'live_session_channel_v2';
        channelName = 'Live Session Alerts';
        break;
      default:
        channelId = 'astology_notifications_v2';
        channelName = 'General Announcements';
    }

    // Force playSound to false globally per user request
    const bool finalPlaySound = false;

    debugPrint('[LocalNotificationService] showNotification | type=$notificationType | channel=$channelId | playSound=$finalPlaySound');

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'System and real-time notifications',
      icon: '@mipmap/ic_launcher',
      importance: finalPlaySound ? Importance.max : Importance.high,
      priority: finalPlaySound ? Priority.high : Priority.defaultPriority,
      playSound: finalPlaySound,
      enableVibration: finalPlaySound,
      showWhen: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: finalPlaySound, // iOS: only plays sound when play_sound == '1'
      ),
    );

    String translatedTitle = title;
    String translatedBody = body;
    try {
      translatedTitle = title.tr;
      translatedBody = body.tr;
    } catch (_) {}

    await _notificationsPlugin.show(
      id,
      translatedTitle,
      translatedBody,
      notificationDetails,
      payload: payload,
    );
  }
}
