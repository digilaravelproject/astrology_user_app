import 'package:astro_user/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_user/features/live/presentation/pages/live_room_screen.dart';
import 'package:astro_user/features/chat/presentation/controllers/chat_controller.dart';
import 'package:astro_user/features/chat_assistance/presentation/controllers/chat_assistance_controller.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/services/websocket/websocket_service.dart';
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
    // 1. Notification Permission is now requested in PermissionScreen

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

        debugPrint('[FCMNotificationService] type=$type playSound=$playSound');

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
        } else if (type == 'assistance_chat' || type == 'chat_assistance') {
          structuredPayload = jsonEncode(message.data);
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

    // 5. Notification Opened Handler (App in Background — user taps FCM notification)
    // We MUST use the same pending-data pattern as cold-start.
    // Direct Get.to() here is unreliable because the widget tree may not be
    // fully ready when the OS resumes the app.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCMNotificationService] onMessageOpenedApp: ${message.data}');
      final data = message.data;
      final type = data['type']?.toString().toLowerCase();
      final screen = data['screen']?.toString().toUpperCase();
      final notifType = data['notification_type']?.toString().toLowerCase();

      final bool isLive = type == 'live_stream' ||
          type == 'live' ||
          type == 'live_session' ||
          screen == 'LIVE_STREAM_SCREEN' ||
          screen == 'LIVE_SESSION_SCREEN' ||
          notifType == 'live_session' ||
          notifType == 'live_stream' ||
          notifType == 'live';

      if (isLive) {
        // Store as pending — DashboardScreen._consumePendingNotification() will
        // navigate to LiveRoomScreen once the widget tree is fully ready.
        final sessionIdStr = data['session_id']?.toString() ??
            data['live_session_id']?.toString() ??
            data['sessionId']?.toString() ??
            data['id']?.toString();
        final int? sessionId = int.tryParse(sessionIdStr ?? '');
        pendingLiveSessionId = sessionId;
        pendingNotificationData = Map<String, dynamic>.from(data);
        debugPrint('[FCMNotificationService] onMessageOpenedApp: pendingLiveSessionId=$sessionId data=$data');
        // Delay slightly so DashboardScreen initState runs first, then trigger consumption
        Future.delayed(const Duration(milliseconds: 600), () {
          _tryNavigateToPendingLive();
        });
      } else {
        // Non-live types: safe to navigate directly after a short delay
        Future.delayed(const Duration(milliseconds: 600), () {
          handleNotificationClick(data);
        });
      }
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
        final type = data['type']?.toString().toLowerCase();
        final screen = data['screen']?.toString().toUpperCase();
        final notifType = data['notification_type']?.toString().toLowerCase();

        final bool isLive = type == 'live_stream' ||
            type == 'live' ||
            type == 'live_session' ||
            screen == 'LIVE_STREAM_SCREEN' ||
            screen == 'LIVE_SESSION_SCREEN' ||
            notifType == 'live_session' ||
            notifType == 'live_stream' ||
            notifType == 'live';

        final bool isChatAssistance = type == 'assistance_chat' || screen == 'ASSISTANCE_CHAT_SCREEN' || 
            notifType == 'assistance_chat' || type == 'chat_assistance';

        if (isLive) {
          // Try every possible session_id key the backend might send
          final sessionIdStr = data['session_id']?.toString() ??
              data['live_session_id']?.toString() ??
              data['sessionId']?.toString() ??
              data['id']?.toString();
          pendingLiveSessionId = int.tryParse(sessionIdStr ?? '');
          pendingNotificationData = Map<String, dynamic>.from(data);
          debugPrint('[FCMNotificationService] Cold-start: pendingLiveSessionId=$pendingLiveSessionId  data=$data');
        } else if (isChatAssistance) {
          pendingNotificationData = Map<String, dynamic>.from(data);
          debugPrint('[FCMNotificationService] Cold-start: pendingNotificationData=$pendingNotificationData');
        } else {
          // For other types try after a safe delay so routes are ready
          Future.delayed(const Duration(milliseconds: 4500), () {
            handleNotificationClick(data);
          });
        }
      }
    });
  }

  /// Navigate to pending live session — called after a safe delay so the
  /// widget tree (DashboardScreen) is guaranteed to be fully mounted.
  static void _tryNavigateToPendingLive() {
    try {
      final int? sessionId = pendingLiveSessionId;
      final Map<String, dynamic>? data = pendingNotificationData;
      if (sessionId == null || sessionId <= 0 || data == null) return;

      // Clear so repeated calls don't re-navigate
      pendingLiveSessionId = null;
      pendingNotificationData = null;

      final String astrologerName =
          data['astrologer_name']?.toString() ??
          data['astrologerName']?.toString() ??
          'Astrologer';
      final String astrologerImage =
          data['astrologer_avatar']?.toString() ??
          data['astrologer_image']?.toString() ??
          data['astrologerImage']?.toString() ??
          '';

      debugPrint('[FCMNotificationService] _tryNavigateToPendingLive: sessionId=$sessionId');
      Get.to(() => LiveRoomScreen(
        sessionId: sessionId,
        astrologerName: astrologerName,
        astrologerImage: astrologerImage,
      ));
    } catch (e) {
      debugPrint('[FCMNotificationService] _tryNavigateToPendingLive error: $e');
    }
  }

  static void handleNotificationClick(Map<String, dynamic> data) {
    try {
      debugPrint('[FCM_SERVICE] Handling notification click with data: $data');
      
      final type = data['type']?.toString();
      final screen = data['screen']?.toString();
      final notificationType = data['notification_type']?.toString();
      final lowerType = type?.toLowerCase() ?? '';

      final bool isLive = lowerType == 'live_stream' ||
          lowerType == 'live' ||
          lowerType == 'live_session' ||
          screen == 'LIVE_STREAM_SCREEN' ||
          screen == 'LIVE_SESSION_SCREEN' ||
          notificationType == 'live_session' ||
          notificationType == 'live_stream' ||
          notificationType == 'live';

      if (isLive) {
        // Use pending mechanism — safe for all app states (foreground/background/killed)
        final sessionIdStr = data['session_id']?.toString() ??
            data['live_session_id']?.toString() ??
            data['sessionId']?.toString() ??
            data['id']?.toString();
        final int? sessionId = int.tryParse(sessionIdStr ?? '');
        if (sessionId != null && sessionId > 0) {
          pendingLiveSessionId = sessionId;
          pendingNotificationData = Map<String, dynamic>.from(data);
          // Navigate after a brief delay to ensure widget tree is ready
          Future.delayed(const Duration(milliseconds: 300), () {
            _tryNavigateToPendingLive();
          });
        }
      } else if (type == 'assistance_chat' || screen == 'ASSISTANCE_CHAT_SCREEN' || notificationType == 'assistance_chat' || type == 'chat_assistance') {
        final astrologerIdStr = data['astrologer_id']?.toString() ?? data['sender_id']?.toString() ?? data['user_id']?.toString();
        if (astrologerIdStr != null && astrologerIdStr.isNotEmpty) {
          final int? astrologerId = int.tryParse(astrologerIdStr);
          if (astrologerId != null) {
            String astrologerName = data['astrologer_name']?.toString() ?? data['sender_name']?.toString() ?? '';
            String astrologerImage = data['astrologer_avatar']?.toString() ?? data['astrologer_image']?.toString() ?? '';
            
            if (astrologerName.isEmpty && data['user_info'] != null) {
               try {
                 final userInfo = data['user_info'] is String ? jsonDecode(data['user_info']) : data['user_info'];
                 astrologerName = userInfo['name']?.toString() ?? '';
                 astrologerImage = userInfo['profile_photo']?.toString() ?? userInfo['image']?.toString() ?? '';
               } catch(_) {}
            }
            if (astrologerName.isEmpty) astrologerName = 'Assistant';
            
            final chatAssistanceController = Get.put(ChatAssistanceController());
            chatAssistanceController.initiateChatAssistance(
              astrologerId,
              astroName: astrologerName,
              astroImage: astrologerImage,
            );
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
    // Run completely in background thread context to prevent UI block (ANR)
    Future.microtask(() async {
      try {
        debugPrint('[FCM_SERVICE] registerDeviceToken background execution started.');
        if (!Get.isRegistered<ApiClient>()) {
          debugPrint('[FCM_SERVICE] ApiClient is NOT registered in GetX container!');
          return;
        }

        // Safe getToken timeout helper to prevent freeze
        String? tokenToRegister = fcmToken;
        if (tokenToRegister == null) {
          try {
            tokenToRegister = await _firebaseMessaging.getToken().timeout(
              const Duration(seconds: 4),
              onTimeout: () {
                debugPrint('[FCM_SERVICE] _firebaseMessaging.getToken timed out.');
                return null;
              },
            );
          } catch (tokEx) {
            debugPrint('[FCM_SERVICE] Error fetching token with timeout: $tokEx');
          }
        }

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
        debugPrint('[FCM_SERVICE] Device token registered response | Status: ${response.statusCode} | Success: ${response.isSuccess}');
      } catch (e, stackTrace) {
        debugPrint('[FCM_SERVICE] Failed to register device token error: $e\n$stackTrace');
      }
    });
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
