import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

enum ColdStartType {
  none,
  call,
  chat,
  live,
  assistanceChat,
}

class ColdStartIntent {
  final ColdStartType type;
  final int sessionId;
  final String? name;
  final String? avatar;
  final String? offerSdp;
  final Map<String, dynamic>? rawData;

  ColdStartIntent({
    required this.type,
    required this.sessionId,
    this.name,
    this.avatar,
    this.offerSdp,
    this.rawData,
  });

  @override
  String toString() {
    return 'ColdStartIntent(type: $type, sessionId: $sessionId, name: $name)';
  }
}

class ColdStartDetector {
  static ColdStartIntent? currentIntent;

  /// Inspects native launch intent across Local Notifications and FCM.
  /// Must be called during pre-runApp initApp() lifecycle.
  static Future<ColdStartIntent?> detect() async {
    try {
      debugPrint('[ColdStartDetector] Scanning native launch intents (User App)...');

      // ── 1. Check FlutterLocalNotificationsPlugin launch details ─────────
      try {
        final launchDetails = await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();
        if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
          final String? payload = launchDetails.notificationResponse?.payload;
          debugPrint('[ColdStartDetector] LocalNotification launch payload: $payload');
          if (payload != null && payload.isNotEmpty) {
            final intent = _parsePayload(payload);
            if (intent != null) {
              currentIntent = intent;
              return intent;
            }
          }
        }
      } catch (e) {
        debugPrint('[ColdStartDetector] LocalNotification check error: $e');
      }

      // ── 2. Check FirebaseMessaging getInitialMessage ────────────────────
      try {
        final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
        if (initialMessage != null && initialMessage.data.isNotEmpty) {
          debugPrint('[ColdStartDetector] FCM initialMessage data: ${initialMessage.data}');
          final intent = _parseFcmData(initialMessage.data);
          if (intent != null) {
            currentIntent = intent;
            return intent;
          }
        }
      } catch (e) {
        debugPrint('[ColdStartDetector] FCM initialMessage check error: $e');
      }

      debugPrint('[ColdStartDetector] No communication cold-start intent found.');
      return null;
    } catch (e) {
      debugPrint('[ColdStartDetector] General detection error: $e');
      return null;
    }
  }

  static ColdStartIntent? _parsePayload(String payload) {
    try {
      // JSON payload (Assistance Chat or Structured FCM)
      if (payload.startsWith('{') && payload.endsWith('}')) {
        final Map<String, dynamic> data = jsonDecode(payload);
        return _parseFcmData(data);
      }

      // live_123
      if (payload.startsWith('live_')) {
        final sIdStr = payload.replaceFirst('live_', '');
        final sId = int.tryParse(sIdStr);
        if (sId != null && sId > 0) {
          return ColdStartIntent(type: ColdStartType.live, sessionId: sId);
        }
      }

      // call_123
      if (payload.startsWith('call_')) {
        final sIdStr = payload.replaceFirst('call_', '');
        final sId = int.tryParse(sIdStr);
        if (sId != null && sId > 0) {
          return ColdStartIntent(type: ColdStartType.call, sessionId: sId);
        }
      }

      // chat_123
      if (payload.startsWith('chat_')) {
        final sIdStr = payload.replaceFirst('chat_', '');
        final sId = int.tryParse(sIdStr);
        if (sId != null && sId > 0) {
          return ColdStartIntent(type: ColdStartType.chat, sessionId: sId);
        }
      }

      // Plain integer sessionId (Chat)
      final sId = int.tryParse(payload);
      if (sId != null && sId > 0) {
        return ColdStartIntent(type: ColdStartType.chat, sessionId: sId);
      }
    } catch (e) {
      debugPrint('[ColdStartDetector] Error parsing payload: $e');
    }
    return null;
  }

  static ColdStartIntent? _parseFcmData(Map<String, dynamic> data) {
    try {
      final type = data['type']?.toString().toLowerCase();
      final screen = data['screen']?.toString().toUpperCase();
      final notificationType = data['notification_type']?.toString().toLowerCase();
      final rawSessionId = data['session_id']?.toString() ??
          data['chat_session_id']?.toString() ??
          data['call_session_id']?.toString() ??
          data['live_session_id']?.toString() ??
          data['chat_assistance_session_id']?.toString() ??
          data['id']?.toString() ?? '';
      final int? sId = int.tryParse(rawSessionId);

      final userName = data['astrologer_name']?.toString() ??
          data['astrologerName']?.toString() ??
          data['user_name']?.toString() ??
          data['sender_name']?.toString() ??
          'Astrologer';
      final userAvatar = data['astrologer_avatar']?.toString() ??
          data['astrologer_image']?.toString() ??
          data['astrologerImage']?.toString() ??
          data['user_avatar']?.toString();

      // Live Stream
      final bool isLive = type == 'live_stream' ||
          type == 'live' ||
          type == 'live_session' ||
          screen == 'LIVE_STREAM_SCREEN' ||
          screen == 'LIVE_SESSION_SCREEN' ||
          notificationType == 'live_session' ||
          notificationType == 'live_stream' ||
          notificationType == 'live';

      if (isLive && sId != null && sId > 0) {
        return ColdStartIntent(
          type: ColdStartType.live,
          sessionId: sId,
          name: userName,
          avatar: userAvatar,
          rawData: data,
        );
      }

      // Assistance Chat
      if (type == 'assistance_chat' || type == 'chat_assistance' || notificationType == 'assistance_chat' || screen == 'ASSISTANCE_CHAT_SCREEN') {
        final astroId = int.tryParse(data['astrologer_id']?.toString() ?? data['sender_id']?.toString() ?? data['user_id']?.toString() ?? '') ?? (sId ?? 0);
        return ColdStartIntent(
          type: ColdStartType.assistanceChat,
          sessionId: astroId,
          name: userName,
          avatar: userAvatar,
          rawData: data,
        );
      }

      if (sId == null || sId <= 0) return null;

      // Call
      final bool isCall = type == 'call' ||
          type == 'call_request' ||
          type == 'call_accepted' ||
          type == 'audio_call' ||
          type == 'video_call';

      if (isCall) {
        return ColdStartIntent(
          type: ColdStartType.call,
          sessionId: sId,
          name: userName,
          avatar: userAvatar,
          rawData: data,
        );
      }

      // Chat
      final bool isChat = type == 'chat' ||
          type == 'chat_request' ||
          type == 'chat_accepted' ||
          type == 'message' ||
          type == 'messagesent';

      if (isChat) {
        return ColdStartIntent(
          type: ColdStartType.chat,
          sessionId: sId,
          name: userName,
          avatar: userAvatar,
          rawData: data,
        );
      }
    } catch (e) {
      debugPrint('[ColdStartDetector] Error parsing FCM data: $e');
    }
    return null;
  }
}
