import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_user/core/utils/logger.dart';
import 'package:astro_user/core/services/websocket/websocket_state.dart';
import 'package:astro_user/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_user/features/chat/presentation/controllers/chat_controller.dart';
import 'package:astro_user/features/chat/domain/usecases/sync_message_status_usecase.dart';
import 'package:astro_user/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_user/core/services/local_notification_service.dart';

import '../../../../features/chat_assistance/presentation/controllers/chat_assistance_controller.dart';

class ChatWsHandler {
  static void handleChatAccepted(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final session = eventData['session'];
      if (session == null) return;

      final int sessionId =
          session['id'] is int
              ? session['id']
              : (int.tryParse(session['id']?.toString() ?? '') ?? 0);
      final String? startedAt = session['started_at']?.toString();
      if (startedAt != null) {
        WebSocketState.sessionStartTimes[sessionId] = startedAt;
      }
      WebSocketState.sessionStatusUpdates[sessionId] = 'ongoing';
      WebSocketState.sessionStatusUpdates.refresh();

      if (FloatingChatBubble.isActive &&
          FloatingChatBubble.sessionId == sessionId) {
        FloatingChatBubble.updateStatus('ongoing');

        int? startedAtMillis;
        if (startedAt != null && startedAt.isNotEmpty) {
          String isoUtc = startedAt.trim().replaceAll(' ', 'T');
          if (!isoUtc.endsWith('Z') &&
              !isoUtc.contains('+') &&
              !isoUtc.contains('-')) {
            isoUtc += 'Z';
          }
          startedAtMillis =
              DateTime.tryParse(isoUtc)?.toLocal().millisecondsSinceEpoch;
        }
        LocalNotificationService.showOngoingChatNotification(
          sessionId: sessionId,
          title: '${FloatingChatBubble.name ?? "Astrologer"} • Chat',
          body: 'Ongoing chat session',
          startedAtMillis: startedAtMillis,
        );
      }

      if (Get.isRegistered<ChatController>()) {
        final controller = Get.find<ChatController>();
        if (controller.sessionId == sessionId) {
          controller.status.value = 'ongoing';
        }
      }
    } catch (e) {
      Logger.e('ChatWsHandler: error handling ChatAccepted -> $e');
    }
  }

  static void handleChatEnded(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final session = eventData['session'];
      if (session == null) return;

      final int sessionId =
          session['id'] is int
              ? session['id']
              : (int.tryParse(session['id']?.toString() ?? '') ?? 0);

      LocalNotificationService.cancelOngoingChatNotification(sessionId);
      FloatingChatBubble.dismiss(stopForegroundService: true);

      if (WebSocketState.activeSessionId == sessionId) {
        WebSocketState.activeSessionId = null;
      }
      WebSocketState.chatEndedSessionId.value = sessionId;
      
      WebSocketState.sessionStatusUpdates[sessionId] = 'ended';
      WebSocketState.sessionStatusUpdates.refresh();
    } catch (e) {
      Logger.e('ChatWsHandler: error handling ChatEnded -> $e');
    }
  }

  static void handleChatDismissed(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final session = eventData['session'];
      if (session == null) return;

      final int sessionId =
          session['id'] is int
              ? session['id']
              : (int.tryParse(session['id']?.toString() ?? '') ?? 0);

      LocalNotificationService.cancelOngoingChatNotification(sessionId);
      FloatingChatBubble.dismiss(stopForegroundService: true);

      WebSocketState.sessionStatusUpdates[sessionId] = 'ended';
      WebSocketState.sessionStatusUpdates.refresh();

      WebSocketState.chatDismissedSessionId.value = sessionId;

      if (WebSocketState.activeSessionId == sessionId) {
        WebSocketState.activeSessionId = null;
      }
    } catch (e) {
      Logger.e('ChatWsHandler: error handling ChatDismissed -> $e');
    }
  }

  static void handleMessageSent(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final messageData = eventData['messageData'] ?? eventData['message'];
      if (messageData != null) {
        final map = Map<String, dynamic>.from(messageData);
        WebSocketState.incomingMessages.add(map);

        final int senderId =
            int.tryParse(map['sender_id']?.toString() ?? '') ?? 0;
        final int sessionId =
            int.tryParse(
              map['chat_assistance_session_id']?.toString() ??
                  map['chat_session_id']?.toString() ??
                  '',
            ) ??
            0;

        if (senderId != WebSocketState.currentUserId) {
          final int messageId = int.tryParse(map['id']?.toString() ?? '') ?? 0;
          if (messageId > 0 && Get.isRegistered<SyncMessageStatusUseCase>()) {
            Get.find<SyncMessageStatusUseCase>()
                .execute(
                  sessionId: sessionId,
                  messageIds: [messageId],
                  status: 'delivered',
                )
                .catchError((e) {
                  debugPrint('Error syncing message status: $e');
                });
          }

          if (WebSocketState.activeSessionId != sessionId) {
            if (FloatingChatBubble.isActive &&
                FloatingChatBubble.sessionId == sessionId) {
              FloatingChatBubble.incrementUnreadCount();
            }
            _showInAppNotification(map);
          }
        }
      }
    } catch (e) {
      Logger.e('ChatWsHandler: error handling MessageSent -> $e');
    }
  }

  static void _showInAppNotification(Map<String, dynamic> msg) {
    final int sessionId =
        int.tryParse(msg['chat_session_id']?.toString() ?? '') ?? 0;
    final String text = msg['message'] ?? 'Sent an attachment';

    try {
      Get.snackbar(
        'New Message',
        text,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        colorText: const Color(0xFF2E1A47),
        icon: const Icon(Icons.message, color: Color(0xFFFF6F00)),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        duration: const Duration(seconds: 4),
        onTap: (_) {
          Get.to(
            () => ChatScreen(
              astrologerName: "Astrologer",
              astrologerImage: "",
              sessionId: sessionId,
              initialStatus: 'ongoing',
            ),
          );
        },
      );
    } catch (e) {
      Logger.e('ChatWsHandler: error showing snackbar -> $e');
    }
  }

  static void handleMessageStatusUpdated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      WebSocketState.messageStatusUpdates.add(eventData);
    } catch (e) {
      Logger.e('ChatWsHandler: error handling MessageStatusUpdated -> $e');
    }
  }

  static void handlePresenceUpdated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      WebSocketState.presenceUpdates.add(eventData);
    } catch (e) {
      Logger.e('ChatWsHandler: error handling PresenceUpdated -> $e');
    }
  }

  static void handleChatAssistanceLimitReached(dynamic rawData) {
    try {
      if (Get.isRegistered<ChatAssistanceController>()) {
        Get.find<ChatAssistanceController>().limitReached.value = true;
      }
    } catch (e) {
      Logger.e('ChatWsHandler: error handling ChatAssistanceLimitReached -> $e');
    }
  }
}
