import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:astro_user/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_user/features/chat/presentation/controllers/chat_controller.dart';
import 'package:astro_user/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_user/features/chat/presentation/pages/chat_screen.dart';

class CallkitService {
  static void init() {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      switch (event) {
        case CallEventActionCallAccept():
          debugPrint('CallKit: Accepted');
          final payload = event.callKitParams.extra?['payload'] as String?;
          final callerName = event.callKitParams.nameCaller;
          final sessionId = event.callKitParams.id;

          // Clean name for display
          if (callerName != null) {
            FloatingChatBubble.name = callerName
                .replaceAll('Chat Req: ', '')
                .replaceAll('Call Req: ', '')
                .trim();
          }

          if (payload != null && payload.startsWith('chat_')) {
            final sId = int.tryParse(payload.replaceFirst('chat_', ''));
            if (sId != null) {
              // End the CallKit session so it doesn't linger as an ongoing telecom call
              if (sessionId != null) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  FlutterCallkitIncoming.endCall(sessionId);
                });
              }

              final astroName = FloatingChatBubble.name ?? 'Astrologer';
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!Get.isRegistered<ChatController>()) {
                  ChatBinding().dependencies();
                }
                Get.to(
                  () => ChatScreen(
                    astrologerName: astroName,
                    astrologerImage: '',
                    sessionId: sId,
                    initialStatus: 'ongoing',
                  ),
                  binding: ChatBinding(),
                );
              });
            }
          }
          break;

        case CallEventActionCallDecline():
          debugPrint('CallKit: Declined');
          final payload = event.callKitParams.extra?['payload'] as String?;

          if (payload != null && payload.startsWith('chat_')) {
            final sId = int.tryParse(payload.replaceFirst('chat_', ''));
            if (sId != null && Get.isRegistered<ChatController>()) {
              Get.find<ChatController>().rejectChatSession();
            }
          }
          break;

        case CallEventActionCallEnded():
          debugPrint('CallKit: Call Ended');
          break;

        case CallEventActionCallTimeout():
          debugPrint('CallKit: Call Timeout');
          break;

        default:
          break;
      }
    });
  }

  static Future<void> showCallkitNotification({
    required String sessionId,
    required String callerName,
    required String avatar,
    required String type, // 'call' or 'chat'
  }) async {
    final String notifTitle =
        type == 'call' ? 'Incoming Call' : 'Chat Request';
    final String nameCallerParam =
        type == 'call' ? callerName : 'Chat Req: $callerName';
    final String payloadStr = '${type}_$sessionId';
    final String safeAvatar =
        (avatar.isNotEmpty && avatar != 'null')
            ? avatar
            : 'assets/images/app_logo.png';

    CallKitParams callKitParams = CallKitParams(
      id: sessionId,
      nameCaller: nameCallerParam,
      appName: 'DigiEmperor Astrology',
      avatar: safeAvatar,
      handle: notifTitle,
      type: 0,
      duration: 30000,
      extra: <String, dynamic>{'payload': payloadStr, 'sessionId': sessionId},
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#FFFFFF',
        backgroundUrl: 'assets/images/background.png',
        actionColor: '#4CAF50',
        textColor: '#000000',
        textAccept: 'Accept',
        textDecline: 'Decline',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }

  static Future<void> showIncomingCall(CallKitParams params) async {
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  static Future<void> endCall(String sessionId) async {
    await FlutterCallkitIncoming.endCall(sessionId);
  }

  static Future<void> endAllCalls() async {
    await FlutterCallkitIncoming.endAllCalls();
  }
}
