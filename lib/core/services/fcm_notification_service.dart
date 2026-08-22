import 'package:astro_user/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_user/features/live/presentation/pages/live_room_screen.dart';
import 'package:astro_user/features/chat/presentation/controllers/chat_controller.dart';
import 'package:astro_user/features/chat_assistance/presentation/controllers/chat_assistance_controller.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/services/network/websocket_service.dart';
import 'local_notification_service.dart';

class FCMNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // ── Pending navigation (Cold Start) ──────────────────────────────────────
  // When the app is killed and user taps a notification, Flutter routes are not
  // ready yet. We store the intent here and SplashController consumes it after
  // navigating to the Dashboard.
  static int? pendingLiveSessionId;
  static Map<String, dynamic>? pendingNotificationData;
  // ─────────────────────────────────────────────────────

  static Future<void> initialize() async {
    // 1. Request Notification Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: false,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    } else {
      debugPrint('User declined notification permission');
    }

    // 2. Get & Register Device Token
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('FCM Token: $token');
        await registerDeviceToken(token);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }

    // 3. Token Refresh Listener
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM Token Refreshed: $newToken');
      await registerDeviceToken(newToken);
    });

    // 4. Foreground Message Handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground Message Received: ${message.notification?.title}');
      if (message.notification != null) {
        final type = message.data['type']?.toString();
        final title = message.notification?.title ?? '';

        // If chat accepted notification arrives while user is on waiting screen, update status to ongoing
        if (title.contains('Accepted') || type == 'chat_accepted' || type == 'CHAT_ACCEPTED' || type == 'chat') {
          final int sessionId = int.tryParse(message.data['session_id']?.toString() ?? message.data['id']?.toString() ?? '') ?? 0;
          if (sessionId > 0) {
            WebSocketService.sessionStatusUpdates[sessionId] = 'ongoing';
            WebSocketService.sessionStatusUpdates.refresh();
          }
        }

        // If chat/call ended message arrives, immediately cancel ongoing timer notification & floating bubble
        if (title.contains('Chat Ended') ||
            type == 'chat_ended' ||
            type == 'CHAT_ENDED' ||
            type == 'session_ended' ||
            type == 'chat_summary') {
          LocalNotificationService.cancelOngoingChatNotification(null);
          FloatingChatBubble.dismiss(stopForegroundService: true);
          return;
        } else if (title.contains('Call Ended') ||
            type == 'call_ended' ||
            type == 'CALL_ENDED' ||
            type == 'session_completed') {
          LocalNotificationService.cancelOngoingCallNotification(null);
          return;
        }

        // Read play_sound from FCM data map (Force disabled per user request)
        // final String playSoundRaw = message.data['play_sound']?.toString() ?? '0';
        // final bool playSound = playSoundRaw == '1' || playSoundRaw == 'true';
        const bool playSound = false; // Audio disabled globally

        debugPrint('[FCMNotificationService] type=$type play_sound=$playSoundRaw → playSound=$playSound');

        // Build a structured payload so onDidReceiveNotificationResponse can route correctly.
        // live_ prefix  → LiveRoomScreen
        // call_ prefix  → CallScreen
        // bare int      → ChatScreen
        final String rawSessionId = message.data['session_id']?.toString() ??
            message.data['chat_session_id']?.toString() ??
            message.data['chat_assistance_session_id']?.toString() ??
            message.data['live_session_id']?.toString() ??
            message.data['id']?.toString() ?? '';

        String structuredPayload;
        if (type == 'live_stream' || type == 'live' || type == 'live_session') {
          structuredPayload = 'live_$rawSessionId';
        } else if (type == 'call' || type == 'CALL_REQUEST' || type == 'CALL_ACCEPTED') {
          structuredPayload = rawSessionId.isNotEmpty ? 'call_$rawSessionId' : message.data.toString();
        } else {
          structuredPayload = rawSessionId.isNotEmpty ? rawSessionId : message.data.toString();
        }

        // ── Suppress notification if user is already viewing that chat session ──
        // Chat/message notifications are noisy when the user is actively in the
        // chat room — WebSocket already delivers the message to the UI.
        final String lowerType = type?.toLowerCase() ?? '';
        final bool isChatType = lowerType.contains('chat') ||
            lowerType.contains('message') ||
            lowerType.contains('messagesent');
        if (isChatType) {
          final int incomingSessionId = int.tryParse(rawSessionId) ?? 0;
          bool userIsOnChatScreen = false;
          try {
            // Check regular chat screen
            if (Get.isRegistered<ChatController>()) {
              final chatCtrl = Get.find<ChatController>();
              if (chatCtrl.sessionId == incomingSessionId) {
                userIsOnChatScreen = true;
              }
            }
            // Check support/assistance chat screen (सहायता चैट)
            if (!userIsOnChatScreen && Get.isRegistered<ChatAssistanceController>()) {
              final assistanceCtrl = Get.find<ChatAssistanceController>();
              if (assistanceCtrl.sessionId == incomingSessionId) {
                userIsOnChatScreen = true;
              }
            }
          } catch (_) {}

          if (userIsOnChatScreen) {
            debugPrint('[FCMNotificationService] Suppressing chat notification — user is on chat screen (sessionId=$incomingSessionId)');
            return; // Skip the notification
          }
        }
        // ──────────────────────────────────────────────────────────────────────────

        LocalNotificationService.showNotification(
          id: message.hashCode,
          title: message.notification?.title ?? 'Notification',
          body: message.notification?.body ?? '',
          payload: structuredPayload,
          notificationType: type,
          playSound: playSound,
        );
      }
    });

    // 5. Notification Opened Handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification Opened App: ${message.data}');
      _handleNotificationClick(message.data);
    });

    // 6. Cold Start / Initial Message Handler
    // When the app is KILLED and user taps the notification, GetX routes are not
    // ready yet. We store the intent in a static field.
    // SplashController reads it AFTER navigation to Dashboard and then opens
    // the target screen.
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('[FCMNotificationService] Cold-start notification detected: ${message.data}');
        final data = message.data;
        final type = data['type']?.toString();
        final screen = data['screen']?.toString();
        final notifType = data['notification_type']?.toString();

        if (type == 'live_stream' || type == 'live' || type == 'live_session' ||
            screen == 'LIVE_STREAM_SCREEN' || notifType == 'live_session') {
          // Store the pending live session so SplashController can navigate after boot
          final sessionIdStr = data['session_id']?.toString() ??
              data['live_session_id']?.toString() ??
              data['id']?.toString();
          pendingLiveSessionId = int.tryParse(sessionIdStr ?? '');
          pendingNotificationData = Map<String, dynamic>.from(data);
          debugPrint('[FCMNotificationService] Cold-start: pendingLiveSessionId=$pendingLiveSessionId');
        } else {
          // For other types try after a safe delay
          Future.delayed(const Duration(milliseconds: 2000), () {
            _handleNotificationClick(data);
          });
        }
      }
    });
  }

  static void _handleNotificationClick(Map<String, dynamic> data) {
    try {
      debugPrint('[FCM_SERVICE] Handling notification click with data: $data');
      
      final type = data['type']?.toString();
      final screen = data['screen']?.toString();
      final notificationType = data['notification_type']?.toString();
      
      if (type == 'live_stream' || screen == 'LIVE_STREAM_SCREEN' || notificationType == 'live_session') {
        final sessionIdStr = data['session_id']?.toString() ?? data['live_session_id']?.toString() ?? data['id']?.toString();
        if (sessionIdStr != null && sessionIdStr.isNotEmpty) {
          final int? sessionId = int.tryParse(sessionIdStr);
          if (sessionId != null) {
            final String astrologerName = data['astrologer_name']?.toString() ?? 'Astrologer';
            final String astrologerImage = data['astrologer_avatar']?.toString() ?? data['astrologer_image']?.toString() ?? '';
            
            // Navigate to LiveRoomScreen
            Get.to(() => LiveRoomScreen(
              sessionId: sessionId,
              astrologerName: astrologerName,
              astrologerImage: astrologerImage,
            ));
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[FCM_SERVICE] Error handling notification click: $e\n$stackTrace');
    }
  }

  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Register or Refresh FCM Device Token on Backend with full real metadata
  static Future<void> registerDeviceToken(String? fcmToken) async {
    try {
      debugPrint('[FCM_SERVICE] registerDeviceToken called. token: $fcmToken');
      if (!Get.isRegistered<ApiClient>()) {
        debugPrint('[FCM_SERVICE] ApiClient is NOT registered in GetX container!');
        return;
      }

      final tokenToRegister = fcmToken ?? await getToken();
      if (tokenToRegister == null || tokenToRegister.isEmpty) {
        debugPrint('[FCM_SERVICE] FCM token is null or empty, skipping API call.');
        return;
      }

      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();

      String deviceId = '';
      String deviceModel = '';
      String deviceType = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown');

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
        deviceModel = '${iosInfo.name} ${iosInfo.model}';
      }

      final payload = {
        'fcm_token': tokenToRegister,
        'device_type': deviceType,
        'device_id': deviceId,
        'device_model': deviceModel,
        'app_version': packageInfo.version,
      };

      debugPrint('[FCM_SERVICE] Sending POST to ${AppUrls.registerDeviceToken} with full payload: $payload');
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(AppUrls.registerDeviceToken, data: payload, handleError: false, showToaster: false);
      debugPrint('[FCM_SERVICE] Device token registered response | Status: ${response.statusCode} | Success: ${response.isSuccess} | Message: ${response.message} | Body: ${response.body}');
    } catch (e, stackTrace) {
      debugPrint('[FCM_SERVICE] Failed to register device token error: $e\n$stackTrace');
    }
  }

  /// Remove Device Token on Logout
  static Future<void> removeDeviceToken() async {
    try {
      if (!Get.isRegistered<ApiClient>()) return;

      final String? fcmToken = await getToken();
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceId = '';

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
      }

      final payload = {
        'device_id': deviceId,
        'fcm_token': fcmToken ?? '',
      };

      debugPrint('[FCM_SERVICE] Sending POST to ${AppUrls.removeDeviceToken} with payload: $payload');
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(AppUrls.removeDeviceToken, data: payload);
      debugPrint('[FCM_SERVICE] Device token removed response: ${response.body}');
    } catch (e) {
      debugPrint('[FCM_SERVICE] Failed to remove device token: $e');
    }
  }
}
