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
          bool isValidStatus = false;
          bool isVisible = false;
          
          if (Get.isRegistered<CallController>()) {
            final ctrl = Get.find<CallController>();
            isVisible = ctrl.isCallScreenVisible;
            final status = ctrl.status.value;
            isValidStatus = (status == 'ongoing' || status == 'ringing' || status == 'dialing' || status == 'waiting');
          }
          
          if (isValidStatus) {
            if (!isVisible) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.to(() => const CallScreen());
              });
            }
          } else {
            // It's a stale notification, cancel it
            debugPrint('[LocalNotificationService] Stale call notification tapped, cancelling...');
            final sessionIdStr = payload.replaceFirst('call_', '');
            final int? sessionId = int.tryParse(sessionIdStr);
            
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

  
  
  
  
  
  
  }
