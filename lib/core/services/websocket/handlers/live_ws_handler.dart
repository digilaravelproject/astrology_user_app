import 'dart:convert';
import 'package:get/get.dart';
import 'package:astro_user/core/utils/logger.dart';
import 'package:astro_user/core/services/websocket/websocket_state.dart';
import 'package:astro_user/features/live/presentation/controllers/live_controller.dart';
import 'package:astro_user/features/live/data/models/live_session_model.dart';

class LiveWsHandler {
  static void handleViewerCountUpdated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      final int sessionId =
          eventData['live_session_id'] is int
              ? eventData['live_session_id']
              : (int.tryParse(eventData['live_session_id']?.toString() ?? '') ??
                  0);
      final int count =
          eventData['viewer_count'] is int
              ? eventData['viewer_count']
              : (int.tryParse(eventData['viewer_count']?.toString() ?? '') ??
                  0);

      WebSocketState.liveViewerCounts[sessionId] = count;
      WebSocketState.liveViewerCounts.refresh();

      if (Get.isRegistered<LiveController>()) {
        final controller = Get.find<LiveController>();
        if (controller.currentSession.value?.id == sessionId) {
          controller.currentSession.value = LiveSessionModel(
            id: controller.currentSession.value!.id,
            title: controller.currentSession.value!.title,
            description: controller.currentSession.value!.description,
            sessionType: controller.currentSession.value!.sessionType,
            status: controller.currentSession.value!.status,
            streamUrl: controller.currentSession.value!.streamUrl,
            viewerCount: count,
            startedAt: controller.currentSession.value!.startedAt,
            astrologer: controller.currentSession.value!.astrologer,
            isBroadcasting: controller.currentSession.value!.isBroadcasting,
          );
          controller.currentSession.refresh();
        }
      }
    } catch (e) {
      Logger.e('LiveWsHandler: error handling ViewerCountUpdated -> $e');
    }
  }

  static void handleNewLiveComment(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final int id =
          eventData['id'] is int
              ? eventData['id']
              : (int.tryParse(eventData['id']?.toString() ?? '') ??
                  DateTime.now().millisecondsSinceEpoch);
      final int userId =
          eventData['user_id'] is int
              ? eventData['user_id']
              : (int.tryParse(eventData['user_id']?.toString() ?? '') ?? 0);
      final String userName = eventData['user_name'] ?? 'User';
      final String? userAvatar =
          eventData['user_avatar'] ?? eventData['user_image'];
      final String message = eventData['message'] ?? '';
      final DateTime createdAt =
          eventData['created_at'] != null
              ? DateTime.tryParse(eventData['created_at']) ?? DateTime.now()
              : DateTime.now();

      if (userId == WebSocketState.currentUserId) {
        return;
      }

      final newComment = LiveCommentModel(
        id: id,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        message: message,
        createdAt: createdAt,
      );

      if (Get.isRegistered<LiveController>()) {
        final controller = Get.find<LiveController>();
        final exists = controller.comments.any((c) => c.id == id);
        if (!exists) {
          controller.comments.add(newComment);
        }
      }
    } catch (e) {
      Logger.e('LiveWsHandler: error handling NewLiveComment -> $e');
    }
  }

  static void handleSuperChatReceived(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final String userName = eventData['user_name'] ?? 'User';
      final String giftTitle =
          eventData['gift'] != null
              ? eventData['gift']['title'] ?? 'Gift'
              : 'Gift';

      if (Get.isRegistered<LiveController>()) {
        final controller = Get.find<LiveController>();
        final newComment = LiveCommentModel(
          id: DateTime.now().millisecondsSinceEpoch,
          userId: eventData['user_id'] is int ? eventData['user_id'] : 0,
          userName: userName,
          userAvatar: eventData['user_avatar'],
          giftIconUrl:
              eventData['gift'] != null ? eventData['gift']['icon_url'] : null,
          message: 'Sent a $giftTitle',
          createdAt: DateTime.now(),
        );
        controller.comments.add(newComment);
      }
    } catch (e) {
      Logger.e('LiveWsHandler: error handling SuperChatReceived -> $e');
    }
  }

  static void handleAstrologerBroadcastStarted(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final int sessionId =
          eventData['live_session_id'] is int
              ? eventData['live_session_id']
              : (int.tryParse(eventData['live_session_id']?.toString() ?? '') ??
                  0);

      if (Get.isRegistered<LiveController>()) {
        final controller = Get.find<LiveController>();
        if (controller.currentSession.value?.id == sessionId) {
          controller.currentSession.value = LiveSessionModel(
            id: controller.currentSession.value!.id,
            title: controller.currentSession.value!.title,
            description: controller.currentSession.value!.description,
            sessionType: controller.currentSession.value!.sessionType,
            status: controller.currentSession.value!.status,
            streamUrl: controller.currentSession.value!.streamUrl,
            viewerCount: controller.currentSession.value!.viewerCount,
            startedAt: controller.currentSession.value!.startedAt,
            astrologer: controller.currentSession.value!.astrologer,
            isBroadcasting: true,
          );
          controller.currentSession.refresh();
        }
      }
    } catch (e) {
      Logger.e(
        'LiveWsHandler: error handling AstrologerBroadcastStarted -> $e',
      );
    }
  }

  static void handleAstrologerMediaStatusChanged(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final String type = eventData['type'] ?? '';
      final String status = eventData['status'] ?? '';

      if (Get.isRegistered<LiveController>()) {
        final controller = Get.find<LiveController>();
        if (type == 'camera') {
          controller.isCameraOn.value = status == 'on';
        } else if (type == 'audio') {
          controller.isAudioOn.value = status == 'on';
        }
      }
    } catch (e) {
      Logger.e(
        'LiveWsHandler: error handling AstrologerMediaStatusChanged -> $e',
      );
    }
  }

  static void handleUserJoinedLiveSession(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final String userName = eventData['user_name'] ?? 'User';
      final String? userAvatar = eventData['user_avatar'];

      final newComment = LiveCommentModel(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: eventData['user_id'] is int ? eventData['user_id'] : 0,
        userName: userName,
        userAvatar: userAvatar,
        message: '$userName joined',
        createdAt: DateTime.now(),
        isSystem: true,
      );

      if (Get.isRegistered<LiveController>()) {
        final controller = Get.find<LiveController>();
        controller.comments.add(newComment);
      }
    } catch (e) {
      Logger.e('LiveWsHandler: error handling UserJoinedLiveSession -> $e');
    }
  }

  static void handleUserLeftLiveSession(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final String userName = eventData['user_name'] ?? 'User';
      final String? userAvatar = eventData['user_avatar'];

      final newComment = LiveCommentModel(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: eventData['user_id'] is int ? eventData['user_id'] : 0,
        userName: userName,
        userAvatar: userAvatar,
        message: '$userName left',
        createdAt: DateTime.now(),
        isSystem: true,
      );

      if (Get.isRegistered<LiveController>()) {
        final controller = Get.find<LiveController>();
        controller.comments.add(newComment);
      }
    } catch (e) {
      Logger.e('LiveWsHandler: error handling UserLeftLiveSession -> $e');
    }
  }

  static void handleLiveSessionEnded(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final int sessionId =
          eventData['session_id'] is int
              ? eventData['session_id']
              : (int.tryParse(eventData['session_id']?.toString() ?? '') ??
                  (eventData['id'] is int
                      ? eventData['id']
                      : (int.tryParse(eventData['id']?.toString() ?? '') ??
                          0)));

      if (Get.isRegistered<LiveController>()) {
        final controller = Get.find<LiveController>();
        if (sessionId == 0 ||
            controller.currentSession.value?.id == sessionId) {
          controller.isCameraOn.value = false;
          controller.isAudioOn.value = false;
          controller.currentSession.value = LiveSessionModel(
            id: controller.currentSession.value!.id,
            title: controller.currentSession.value!.title,
            description: controller.currentSession.value!.description,
            sessionType: controller.currentSession.value!.sessionType,
            status: 'completed',
            streamUrl: controller.currentSession.value!.streamUrl,
            viewerCount: controller.currentSession.value!.viewerCount,
            startedAt: controller.currentSession.value!.startedAt,
            astrologer: controller.currentSession.value!.astrologer,
            isBroadcasting: false,
          );
          controller.currentSession.refresh();
        }
      }
    } catch (e) {
      Logger.e('LiveWsHandler: error handling LiveSessionEnded -> $e');
    }
  }

  static void handleLiveSessionStarted(dynamic rawData) {
    try {
      if (Get.isRegistered<LiveController>()) {
        Get.find<LiveController>().fetchActiveSessions();
      }
    } catch (e) {
      Logger.e('LiveWsHandler: error handling LiveSessionStarted -> $e');
    }
  }

  static void handleActiveLiveSessionsUpdated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      if (Get.isRegistered<LiveController>()) {
        Get.find<LiveController>().updateActiveSessionsFromEvent(eventData);
      }
    } catch (e) {
      Logger.e('LiveWsHandler: error handling ActiveLiveSessionsUpdated -> $e');
    }
  }
}
