import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:astro_user/features/chat/domain/entities/chat_message.dart';
import 'package:astro_user/core/services/websocket/websocket_service.dart';
import 'package:astro_user/core/services/foreground_task_service.dart';
import 'package:astro_user/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_user/core/services/storage/shared_prefs.dart';
import 'package:astro_user/core/constants/app_constants.dart';
import 'package:astro_user/features/auth/data/models/user_model.dart';
import 'package:astro_user/core/services/local_notification_service.dart';
import 'chat_session_controller.dart';
import 'chat_message_controller.dart';

class ChatController extends GetxController {
  final ChatSessionController session;
  final ChatMessageController messaging;

  ChatController({required this.session, required this.messaging});

  // Orchestrator State
  int? sessionId;
  int? currentUserId;
  int? peerId;
  String? astrologerName;

  // Delegates for backward compatibility
  RxList<ChatMessage> get messages => messaging.messages;
  RxBool get isLoading => session.isLoading;
  RxString get status => session.status;
  RxInt get elapsedSeconds => session.elapsedSeconds;
  RxInt get currentPingMs => WebSocketService.currentPingMs;
  Rx<ChatMessage?> get replyingToMessage => messaging.replyingToMessage;
  TextEditingController get messageController => messaging.messageController;
  ScrollController get scrollController => messaging.scrollController;

  bool get isPackageChat => session.isPackageChat;
  set isPackageChat(bool val) => session.isPackageChat = val;
  bool get isCallAlsoActive => session.isCallAlsoActive;
  set isCallAlsoActive(bool val) => session.isCallAlsoActive = val;

  void initSession({
    required int sessionId,
    required int currentUserId,
    required String initialStatus,
    required String astrologerName,
    String? startedAtString,
  }) {
    if (this.sessionId != sessionId) {
      messaging.messages.clear();
      this.sessionId = sessionId;
    }
    
    if (currentUserId != 0) {
      this.currentUserId = currentUserId;
    } else {
      this.currentUserId = WebSocketService.currentUserId;
      if (this.currentUserId == null || this.currentUserId == 0) {
        try {
          final userDataStr = SharedPrefs.getString(AppConstants.userData);
          if (userDataStr != null && userDataStr.isNotEmpty) {
            final userModel = UserModel.fromJsonString(userDataStr);
            this.currentUserId = userModel?.id;
            WebSocketService.currentUserId = this.currentUserId;
          }
        } catch (_) {}
      }
    }
    this.astrologerName = astrologerName;
    if (session.status.value != 'ongoing' && session.status.value != 'accepted') {
      session.status.value = initialStatus;
    }
    session.startedAt = startedAtString;

    WebSocketService.activeSessionId = sessionId;

    messaging.loadHistory();
    session.setupTimer(startedAtString);

    final startedAtStr = startedAtString ?? WebSocketService.sessionStartTimes[sessionId];
    int? startedAtMillis;
    if (startedAtStr != null) {
      final startedAt = DateTime.tryParse(startedAtStr);
      if (startedAt != null) {
        startedAtMillis = startedAt.millisecondsSinceEpoch;
      }
    }

    if (session.status.value == 'ongoing' || session.status.value == 'initiated' || session.status.value == 'ringing') {
      if (session.status.value == 'initiated' || session.status.value == 'ringing') {
        session.startRingtone();
      }
      LocalNotificationService.showOngoingChatNotification(
        sessionId: sessionId,
        title: session.status.value == 'ongoing' ? 'Chat in progress' : 'Waiting for acceptance...',
        body: 'Active chat with $astrologerName',
        startedAtMillis: session.status.value == 'ongoing' ? startedAtMillis : null,
      );
    }

    ever(session.status, (val) {
      if (FloatingChatBubble.isActive && FloatingChatBubble.sessionId == sessionId) {
        FloatingChatBubble.updateStatus(val);
      }
    });

    messaging.setupMessageListeners();
    session.setupSessionListeners();
  }

  void setReply(ChatMessage message) => messaging.setReply(message);
  void cancelReply() => messaging.cancelReply();
  
  Future<void> sendTextMessage() => messaging.sendTextMessage();
  Future<void> sendImageAttachment(XFile file) => messaging.sendImageAttachment(file);
  Future<void> sendDocumentAttachment(PlatformFile file) => messaging.sendDocumentAttachment(file);
  Future<void> markRead() => messaging.markRead();
  
  Future<void> terminateChannelOnly() => session.terminateChannelOnly();
  Future<void> terminateEntireSession() => session.terminateEntireSession();
  Future<void> rejectChatSession() => session.rejectChatSession();
  Future<void> endChatSession({bool skipSummary = false}) => session.endChatSession(skipSummary: skipSummary);
  void minimizeToBubble(BuildContext ctx, String name, String image, {bool shouldPop = true}) => session.minimizeToBubble(ctx, name, image, shouldPop: shouldPop);
}
