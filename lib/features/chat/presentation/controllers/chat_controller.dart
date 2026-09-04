import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:astro_user/core/services/network/websocket_service.dart';
import 'package:astro_user/features/chat/domain/entities/chat_message.dart';
import 'package:astro_user/features/chat/data/models/chat_message_model.dart';
import 'package:astro_user/features/chat/domain/usecases/end_chat_session_usecase.dart';
import 'package:astro_user/features/chat/domain/usecases/reject_chat_session_usecase.dart';
import 'package:astro_user/features/chat/domain/usecases/load_chat_history_usecase.dart';
import 'package:astro_user/features/chat/domain/usecases/mark_messages_read_usecase.dart';
import 'package:astro_user/features/chat/domain/usecases/send_attachment_usecase.dart';
import 'package:astro_user/features/chat/domain/usecases/send_text_message_usecase.dart';
import 'package:astro_user/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_user/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_user/core/services/local_notification_service.dart';
import 'package:astro_user/core/services/sound_vibration_service.dart';
import 'package:astro_user/core/services/storage/shared_prefs.dart';
import 'package:astro_user/core/constants/app_constants.dart';
import 'package:astro_user/features/auth/domain/models/user_model.dart';

import 'package:astro_user/features/chat/presentation/widgets/chat_summary_dialog.dart';
import 'package:astro_user/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_user/core/services/foreground_task_service.dart';
import 'package:astro_user/core/utils/custom_snackbar.dart';
import 'package:astro_user/core/utils/logger.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/utils/session_bottom_sheet_helper.dart';
import 'package:astro_user/features/chat/domain/entities/chat_session.dart';
import 'package:astro_user/features/auth/controllers/auth_controller.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ChatController extends GetxController with WidgetsBindingObserver {
  final LoadChatHistoryUseCase _loadChatHistoryUseCase;
  final SendTextMessageUseCase _sendTextMessageUseCase;
  final SendAttachmentUseCase _sendAttachmentUseCase;
  final MarkMessagesReadUseCase _markMessagesReadUseCase;
  final EndChatSessionUseCase _endChatSessionUseCase;
  final RejectChatSessionUseCase _rejectChatSessionUseCase;

  ChatController({
    required LoadChatHistoryUseCase loadChatHistoryUseCase,
    required SendTextMessageUseCase sendTextMessageUseCase,
    required SendAttachmentUseCase sendAttachmentUseCase,
    required MarkMessagesReadUseCase markMessagesReadUseCase,
    required EndChatSessionUseCase endChatSessionUseCase,
    required RejectChatSessionUseCase rejectChatSessionUseCase,
  })  : _loadChatHistoryUseCase = loadChatHistoryUseCase,
        _sendTextMessageUseCase = sendTextMessageUseCase,
        _sendAttachmentUseCase = sendAttachmentUseCase,
        _markMessagesReadUseCase = markMessagesReadUseCase,
        _endChatSessionUseCase = endChatSessionUseCase,
        _rejectChatSessionUseCase = rejectChatSessionUseCase;

  void _startRingtone() {
    SoundVibrationService().startRingtone('audio/user_app_sound.mp3', loop: true, vibrate: true);
  }

  void _stopRingtone() {
    SoundVibrationService().stopRingtone();
  }

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxString status = 'connecting'.obs; // ongoing, ended
  final RxInt elapsedSeconds = 0.obs;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  final Rx<ChatMessage?> replyingToMessage = Rx<ChatMessage?>(null);

  void setReply(ChatMessage message) {
    String cleanText = message.text;
    if (cleanText.startsWith('>>reply>>')) {
      final endQuote = cleanText.indexOf('<<reply<<');
      if (endQuote != -1) {
        cleanText = cleanText.substring(endQuote + 9).trimLeft();
      }
    }
    replyingToMessage.value = message.copyWith(text: cleanText);
  }

  void cancelReply() {
    replyingToMessage.value = null;
  }

  int? _sessionId;
  int? _currentUserId;
  int? _peerId;
  String? _astrologerName;
  Timer? _timer;
  String? _startedAt;
  StreamSubscription? _msgSub;
  StreamSubscription? _endSub;
  StreamSubscription? _statusSub;
  StreamSubscription? _dismissSub;
  StreamSubscription? _statusUpdateSub;
  StreamSubscription? _packageTerminatedSub;

  int? get sessionId => _sessionId;
  int? get peerId => _peerId;
  bool isPackageChat = false;
  /// True when the package sub-session also has an active call channel
  bool isCallAlsoActive = false;

  // ─── Hybrid Package: Granular Channel Termination (Chat Screen) ──────────

  /// End Chat Only — terminates chat channel but keeps call active
  Future<void> terminateChannelOnly() async {
    final subId = PackageSessionService.activeSubSessionId ?? SessionBottomSheetHelper.activeSubSessionId;
    if (subId == null) {
      Logger.e('ChatController: terminateChannelOnly — no activeSubSessionId found');
      return;
    }
    try {
      isLoading.value = true;
      await PackageSessionService.terminateChannel(
        subSessionId: subId,
        channelType: 'chat',
        action: 'channel_only',
      );
      Logger.d('ChatController: terminateChannelOnly success.');
      
      // Update local state to show chat is ended/completed
      status.value = 'ended';
      _timer?.cancel();
      ForegroundTaskService.stopService();
      if (_sessionId != null) {
        LocalNotificationService.cancelOngoingChatNotification(_sessionId!);
      }
      FloatingChatBubble.dismiss();
      WebSocketService.activeSessionId = null;
      
      // Navigate back
      Get.back();
    } catch (e) {
      Logger.e('ChatController: Error in terminateChannelOnly -> $e');
      CustomSnackbar.showError('Failed to end chat. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// End Entire Session — terminates both chat and call channels
  Future<void> terminateEntireSession() async {
    final subId = PackageSessionService.activeSubSessionId ?? SessionBottomSheetHelper.activeSubSessionId;
    if (subId == null) {
      // Fallback
      await endChatSession();
      return;
    }
    try {
      isLoading.value = true;
      await PackageSessionService.terminateChannel(
        subSessionId: subId,
        channelType: 'chat',
        action: 'complete_session',
      );
      Logger.d('ChatController: terminateEntireSession success.');
      
      status.value = 'ended';
      _timer?.cancel();
      ForegroundTaskService.stopService();
      if (_sessionId != null) {
        LocalNotificationService.cancelOngoingChatNotification(_sessionId!);
      }
      FloatingChatBubble.dismiss();
      WebSocketService.activeSessionId = null;
      
      Get.back();
    } catch (e) {
      Logger.e('ChatController: Error in terminateEntireSession -> $e');
      await endChatSession();
    } finally {
      isLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    scrollController.addListener(_scrollListener);
    ForegroundTaskService.listenTaskData((data) {
      if (data is Map && data['action'] == 'hangup') {
        if (_sessionId != null) {
          endChatSession();
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if ((status.value == 'ongoing' || status.value == 'initiated') && _sessionId != null && _astrologerName != null) {
        minimizeToBubble(Get.context!, _astrologerName!, "", shouldPop: false);
      }
    }
  }

  void initSession({
    required int sessionId,
    required int currentUserId,
    required String initialStatus,
    required String astrologerName,
    String? startedAtString,
  }) {
    if (_sessionId != sessionId) {
      messages.clear();
      _sessionId = sessionId;
    }
    _packageTerminatedSub?.cancel();
    _packageTerminatedSub = WebSocketService.isPackageSessionTerminated.listen((isTerminated) {
      if (isTerminated && isPackageChat) {
        _handlePackageTerminated();
      }
    });
    if (currentUserId != 0) {
      _currentUserId = currentUserId;
    } else {
      _currentUserId = WebSocketService.currentUserId;
      if (_currentUserId == null || _currentUserId == 0) {
        try {
          final userDataStr = SharedPrefs.getString(AppConstants.userData);
          if (userDataStr != null && userDataStr.isNotEmpty) {
            final userModel = UserModel.fromJsonString(userDataStr);
            _currentUserId = userModel?.id;
            WebSocketService.currentUserId = _currentUserId;
          }
        } catch (_) {}
      }
    }
    _astrologerName = astrologerName;
    if (status.value != 'ongoing' && status.value != 'accepted') {
      status.value = initialStatus;
    }
    _startedAt = startedAtString;

    WebSocketService.activeSessionId = sessionId;

    // Load Chat history
    loadHistory();

    // Setup timer if started at is known
    _setupTimer(startedAtString);

    final startedAtStr = startedAtString ?? WebSocketService.sessionStartTimes[_sessionId];
    int? startedAtMillis;
    if (startedAtStr != null) {
      final startedAt = DateTime.tryParse(startedAtStr);
      if (startedAt != null) {
        startedAtMillis = startedAt.millisecondsSinceEpoch;
      }
    }

    // Show ongoing local notification
    if (status.value == 'ongoing' || status.value == 'initiated' || status.value == 'ringing') {
      if (status.value == 'initiated' || status.value == 'ringing') {
        _startRingtone();
      }
      LocalNotificationService.showOngoingChatNotification(
        sessionId: sessionId,
        title: status.value == 'ongoing' ? 'Chat in progress' : 'Waiting for acceptance...',
        body: 'Active chat with $astrologerName',
        startedAtMillis: status.value == 'ongoing' ? startedAtMillis : null,
      );
    }

    ever(status, (val) {
      if (FloatingChatBubble.isActive && FloatingChatBubble.sessionId == _sessionId) {
        FloatingChatBubble.updateStatus(val);
      }
    });

    // Listen to WebSocket Incoming Messages
    _msgSub?.cancel();
    _msgSub = WebSocketService.incomingMessages.listen((list) {
      if (list.isNotEmpty) {
        final lastMsg = list.last;
        final msgSessionId = int.tryParse(lastMsg['chat_session_id']?.toString() ?? '') ?? 0;
        if (msgSessionId == _sessionId) {
          final int senderId = int.tryParse(lastMsg['sender_id']?.toString() ?? '') ?? 0;
          final bool isMe = senderId == _currentUserId;

          if (status.value == 'initiated' || status.value == 'ringing') {
            status.value = 'ongoing';
            _stopRingtone();
            _setupTimer(null);
          }

          final int msgId = int.tryParse(lastMsg['id']?.toString() ?? '') ?? 0;
          final String msgText = lastMsg['message']?.toString() ?? '';
          final String msgType = lastMsg['type']?.toString() ?? 'text';

          // Guard: already in list with the real server id → skip
          if (messages.any((m) => m.id == msgId)) return;

          if (isMe) {
            // ── My own message echoed back from WebSocket ──────────────────
            // Find the optimistic placeholder (status='sending...', same text, or same type if image/file)
            // and upgrade it in-place. This prevents the duplicate that occurs
            // when the echo arrives BEFORE the API response updates the tempId.
            final pendingIndex = messages.indexWhere(
              (m) => m.isMe && m.status == 'sending...' && 
                     (m.text.replaceAll(RegExp(r'\s+'), '') == msgText.replaceAll(RegExp(r'\s+'), '') || 
                      (m.type == 'image' && msgType == 'image') || 
                      (m.type == 'file' && msgType == 'file')),
            );
            if (pendingIndex != -1) {
              // Replace the placeholder with the confirmed server message
              messages[pendingIndex] = messages[pendingIndex].copyWith(
                id: msgId,
                status: 'sent',
                time: DateTime.tryParse(lastMsg['created_at']?.toString() ?? '') ?? messages[pendingIndex].time,
                attachmentUrl: lastMsg['attachment_url']?.toString(),
                image: msgType == 'image' ? lastMsg['attachment_url']?.toString() : null,
                type: msgType,
              );
              messages.refresh();
            }
            // If no placeholder found (e.g. another device), fall through and add normally
            else {
              messages.add(ChatMessageModel.fromJson(lastMsg, currentUserId: _currentUserId!));
              _scrollToBottom();
            }
          } else {
            // ── Message from the other side ────────────────────────────────
            messages.add(ChatMessageModel.fromJson(lastMsg, currentUserId: _currentUserId!));
            _scrollToBottom();
            markRead();
          }
        }
      }
    });
    // Listen to WebSocket Message Status Updates (delivered/seen)
    _statusUpdateSub?.cancel();
    _statusUpdateSub = WebSocketService.messageStatusUpdates.listen((list) {
      if (list.isNotEmpty) {
        bool changed = false;
        for (var lastUpdate in list) {
          final updateSessionId = int.tryParse(
            lastUpdate['session_id']?.toString() ?? 
            lastUpdate['chat_session_id']?.toString() ?? 
            lastUpdate['chat_assistance_session_id']?.toString() ?? 
            lastUpdate['sessionId']?.toString() ?? ''
          ) ?? 0;
          if (updateSessionId == _sessionId) {
            final newStatus = lastUpdate['status']?.toString();
            final messageIdsList = (lastUpdate['message_ids'] ?? lastUpdate['messageIds']) as List<dynamic>?;
            if (newStatus != null && messageIdsList != null && messageIdsList.isNotEmpty) {
              final messageIds = messageIdsList.map((e) => int.tryParse(e.toString()) ?? 0).toList();
              debugPrint('[ChatController][STATUS_DEBUG] Event: newStatus=$newStatus, messageIds=$messageIds');
              for (int i = 0; i < messages.length; i++) {
                if (messageIds.contains(messages[i].id)) {
                  debugPrint('[ChatController][STATUS_DEBUG] Matching message found: id=${messages[i].id}, currentStatus=${messages[i].status}');
                  if (newStatus == 'seen' && messages[i].status != 'seen') {
                    messages[i] = messages[i].copyWith(status: 'seen');
                    changed = true;
                    debugPrint('[ChatController][STATUS_DEBUG] Updated message ${messages[i].id} to seen');
                  } else if (newStatus == 'delivered' && messages[i].status == 'sent') {
                    messages[i] = messages[i].copyWith(status: 'delivered');
                    changed = true;
                    debugPrint('[ChatController][STATUS_DEBUG] Updated message ${messages[i].id} to delivered');
                  }
                }
              }
            }
          }
        }
        if (changed) {
          messages.refresh();
        }
      }
    });

    // Listen to WebSocket Chat Ended Event
    _endSub?.cancel();

    // Check if already ended before we started listening
    if (WebSocketService.chatEndedSessionId.value == _sessionId) {
      _handleChatEndedByPeer();
    }

    _endSub = WebSocketService.chatEndedSessionId.listen((endedSessionId) {
      if (endedSessionId == _sessionId) {
        _handleChatEndedByPeer();
      }
    });

    // Listen to WebSocket Chat Dismissed Event
    _dismissSub?.cancel();
    
    // Check if already dismissed before we started listening
    if (WebSocketService.chatDismissedSessionId.value == _sessionId) {
      _handleDismissed();
    }

    _dismissSub = WebSocketService.chatDismissedSessionId.listen((dismissedSessionId) {
      if (dismissedSessionId == _sessionId) {
        _handleDismissed();
      }
    });

    // Listen to WebSocket Session Status Updates (e.g. ChatAccepted)
    _statusSub?.cancel();
    if (_sessionId != null && WebSocketService.sessionStatusUpdates.containsKey(_sessionId)) {
      final cachedStatus = WebSocketService.sessionStatusUpdates[_sessionId!];
      if (cachedStatus != null && (cachedStatus == 'ongoing' || cachedStatus == 'accepted') && (status.value != 'ongoing' && status.value != 'accepted')) {
        status.value = cachedStatus;
        _stopRingtone();
        _setupTimer(_startedAt);
      }
    }
    _statusSub = WebSocketService.sessionStatusUpdates.listen((updates) {
      if (_sessionId != null && updates.containsKey(_sessionId)) {
        final newStatus = updates[_sessionId!];
        if (newStatus != null && status.value != newStatus) {
          status.value = newStatus;
          if (newStatus == 'ongoing' || newStatus == 'accepted') {
            _stopRingtone();
            final startedAtStr = WebSocketService.sessionStartTimes[_sessionId];
            DateTime? serverStartTime;
            if (startedAtStr != null && startedAtStr.isNotEmpty) {
              String isoUtc = startedAtStr.trim().replaceAll(' ', 'T');
              if (!isoUtc.endsWith('Z') && !isoUtc.contains('+') && !isoUtc.contains('-')) {
                isoUtc += 'Z';
              }
              serverStartTime = DateTime.tryParse(isoUtc)?.toLocal();
            }
            
            final effectiveStart = serverStartTime ?? DateTime.now();
            _startedAt = effectiveStart.toIso8601String();
            if (_sessionId != null) {
              WebSocketService.sessionStartTimes[_sessionId!] = _startedAt!;
            }
            final diff = DateTime.now().difference(effectiveStart).inSeconds;
            elapsedSeconds.value = diff >= 0 ? diff : 0;

            _setupTimer(_startedAt);
            // FlutterBackgroundService().startService(); // Disabled to prevent OOM crash on low-resource devices
            
            final startedAtMillis = effectiveStart.millisecondsSinceEpoch;
            LocalNotificationService.showOngoingChatNotification(
              sessionId: _sessionId!,
              title: 'Chat in progress',
              body: 'Active chat with ${_astrologerName ?? 'Astrologer'}',
              startedAtMillis: startedAtMillis,
            );
          }
        }
      }
    });
  }

  void _handleChatEndedByPeer() {
    status.value = 'ended';
    _timer?.cancel();
    ForegroundTaskService.stopService();
    if (_sessionId != null) {
      LocalNotificationService.cancelOngoingChatNotification(_sessionId!);
    }
    FloatingChatBubble.dismiss();
    if (Get.isRegistered<AuthController>()) {
      Get.find<AuthController>().checkLoginStatus();
    }
    Future.delayed(const Duration(milliseconds: 400), () {
      if (Get.isRegistered<ChatController>()) {
        Get.back();
      }
    });
  }

  void _handleDismissed() {
    _stopRingtone();
    status.value = 'ended';
    _timer?.cancel();
    ForegroundTaskService.stopService();
    if (_sessionId != null) {
      LocalNotificationService.cancelOngoingChatNotification(_sessionId!);
    }
    FloatingChatBubble.dismiss();
    Get.back();
  }

  DateTime? _parseSmartDate(dynamic input) {
    if (input == null) return null;
    if (input is DateTime) return input.toLocal();
    final dateStr = input.toString().trim();
    if (dateStr.isEmpty) return null;

    String isoUtc = dateStr.replaceAll(' ', 'T');
    if (!isoUtc.endsWith('Z') && !isoUtc.contains('+') && !isoUtc.contains('-')) {
      isoUtc += 'Z';
    }
    final utcDate = DateTime.tryParse(isoUtc)?.toLocal();
    if (utcDate != null) {
      final now = DateTime.now();
      if (!utcDate.isAfter(now)) {
        return utcDate;
      }
    }

    DateTime? parsed = DateTime.tryParse(dateStr.replaceAll(' ', 'T')) ?? DateTime.tryParse(dateStr);
    if (parsed == null) return null;
    return parsed.toLocal();
  }

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _setupTimer(String? startedAtString) {
    _timer?.cancel();
    final currentSt = status.value.toLowerCase();
    if (currentSt == 'ended' || currentSt == 'completed' || currentSt == 'cancelled' || currentSt == 'rejected') return;

    if (startedAtString != null && _sessionId != null) {
      _startedAt = startedAtString;
      WebSocketService.sessionStartTimes[_sessionId!] = startedAtString;
    }

    final startedAtStr = startedAtString ?? _startedAt ?? (_sessionId != null ? WebSocketService.sessionStartTimes[_sessionId] : null);
    final startedAt = _parseSmartDate(startedAtStr);

    if (startedAt != null) {
      final st = status.value.toLowerCase();
      if (st == 'ongoing' || st == 'accepted') {
        final diff = DateTime.now().difference(startedAt).inSeconds;
        
        if (FloatingChatBubble.isActive && FloatingChatBubble.sessionId == _sessionId) {
          elapsedSeconds.value = FloatingChatBubble.currentElapsedSeconds;
        } else if (diff >= 0) {
          elapsedSeconds.value = diff;
        } else {
          elapsedSeconds.value = 0;
        }
      }

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final st = status.value.toLowerCase();
        if (st == 'ended' || st == 'completed' || st == 'cancelled' || st == 'rejected') {
          timer.cancel();
          return;
        }
        if (st == 'ongoing' || st == 'accepted') {
          final nowDiff = DateTime.now().difference(startedAt).inSeconds;
          
          if (FloatingChatBubble.isActive && FloatingChatBubble.sessionId == _sessionId) {
            elapsedSeconds.value++;
            FloatingChatBubble.updateStatus(status.value);
          } else if (nowDiff >= 0) {
            elapsedSeconds.value = nowDiff;
          } else {
            elapsedSeconds.value++;
          }
        }
        // Do not reset to 0, just pause updating if not ongoing
      });
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final st = status.value.toLowerCase();
        if (st == 'ended' || st == 'completed' || st == 'cancelled' || st == 'rejected') {
          timer.cancel();
          return;
        }
        if (st == 'ongoing' || st == 'accepted') {
          elapsedSeconds.value++;
          if (_sessionId != null) {
            final genStart = DateTime.now().subtract(Duration(seconds: elapsedSeconds.value)).toIso8601String();
            _startedAt = genStart;
            WebSocketService.sessionStartTimes[_sessionId!] = genStart;
          }
        }
      });
    }
  }

  Future<void> loadHistory() async {
    if (_sessionId == null || _currentUserId == null) return;
    isLoading.value = true;
    try {
      final result = await _loadChatHistoryUseCase.execute(
        sessionId: _sessionId!,
        currentUserId: _currentUserId!,
      );
      messages.assignAll(result.messages);
      _peerId = result.peerId;
      if (result.sessionStatus != null && (result.sessionStatus == 'ongoing' || result.sessionStatus == 'accepted')) {
        status.value = 'ongoing';
        _stopRingtone();
      }
      if (result.startedAt != null && (status.value == 'ongoing' || status.value == 'accepted')) {
        _startedAt = result.startedAt;
        _setupTimer(result.startedAt);
      }
      _scrollToBottom();
      markRead();
    } catch (e) {
      debugPrint("Error loading chat history: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String _getLatestStatus(int messageId, String defaultStatus) {
    String currentStatus = defaultStatus;
    for (var event in WebSocketService.messageStatusUpdates) {
      final updateSessionId = int.tryParse(
        event['session_id']?.toString() ?? 
        event['chat_session_id']?.toString() ?? 
        event['chat_assistance_session_id']?.toString() ?? 
        event['sessionId']?.toString() ?? ''
      ) ?? 0;
      if (updateSessionId == _sessionId) {
        final messageIdsList = (event['message_ids'] ?? event['messageIds']) as List<dynamic>?;
        if (messageIdsList != null) {
          final messageIds = messageIdsList.map((e) => int.tryParse(e.toString()) ?? 0).toList();
          if (messageIds.contains(messageId)) {
            final newStatus = event['status']?.toString();
            debugPrint('[ChatController][STATUS_DEBUG] _getLatestStatus matching event found for messageId=$messageId: newStatus=$newStatus');
            if (newStatus == 'seen' || (newStatus == 'delivered' && currentStatus != 'seen')) {
              currentStatus = newStatus!;
            }
          }
        }
      }
    }
    debugPrint('[ChatController][STATUS_DEBUG] _getLatestStatus returning $currentStatus for messageId=$messageId');
    return currentStatus;
  }

  Future<void> sendTextMessage() async {
    String text = messageController.text.trim();
    if (text.isEmpty || _sessionId == null) return;

    final replyToMessage = replyingToMessage.value;
    final replyToId = replyToMessage?.id;
    
    cancelReply();
    messageController.clear();

    // Local temporary ID for UI responsiveness
    final tempId = DateTime.now().millisecondsSinceEpoch;
    final localMsg = ChatMessage(
      id: tempId,
      text: text,
      isMe: true,
      time: DateTime.now(),
      status: 'sending...',
      type: 'text',
      replyToId: replyToId,
      replyTo: replyToMessage,
    );
    messages.add(localMsg);
    _scrollToBottom();

    try {
      final serverId = await _sendTextMessageUseCase.execute(
        sessionId: _sessionId!,
        text: text,
        replyToId: replyToId,
      );

      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        if (serverId != null) {
          final newStatus = _getLatestStatus(serverId, 'sent');
          messages[index] = messages[index].copyWith(id: serverId, status: newStatus);
        } else {
          messages[index] = messages[index].copyWith(status: 'failed');
        }
        messages.refresh();
      }
    } catch (_) {
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: 'failed');
      }
    }
  }

  Future<void> sendImageAttachment(XFile xFile) async {
    if (_sessionId == null) return;

    final tempId = DateTime.now().millisecondsSinceEpoch;
    final localMsg = ChatMessage(
      id: tempId,
      text: '📷 Sending Image...',
      isMe: true,
      time: DateTime.now(),
      status: 'sending...',
      image: xFile.path,
      type: 'image',
    );
    messages.add(localMsg);
    _scrollToBottom();

    try {
      final result = await _sendAttachmentUseCase.executeImage(
        sessionId: _sessionId!,
        file: xFile,
      );

      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        if (result != null) {
          final newStatus = _getLatestStatus(result!.id, 'sent');
          messages[index] = messages[index].copyWith(
            id: result!.id,
            status: newStatus,
            attachmentUrl: result!.url,
            image: result!.url,
          );
        } else {
          messages[index] = messages[index].copyWith(status: 'failed');
        }
        messages.refresh();
      }
    } catch (_) {
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: 'failed');
      }
    }
  }

  Future<void> sendDocumentAttachment(PlatformFile platformFile) async {
    if (_sessionId == null) return;

    final tempId = DateTime.now().millisecondsSinceEpoch;
    final localMsg = ChatMessage(
      id: tempId,
      text: '📄 ${platformFile.name}',
      isMe: true,
      time: DateTime.now(),
      status: 'sending...',
      type: 'document',
    );
    messages.add(localMsg);
    _scrollToBottom();

    try {
      final pickerResult = FilePickerResult([platformFile]);
      final result = await _sendAttachmentUseCase.executeDocument(
        sessionId: _sessionId!,
        fileName: platformFile.name,
        result: pickerResult,
      );

      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        if (result != null) {
          final newStatus = _getLatestStatus(result!.id, 'sent');
          messages[index] = messages[index].copyWith(
            id: result!.id,
            status: newStatus,
            attachmentUrl: result!.url,
          );
        } else {
          messages[index] = messages[index].copyWith(status: 'failed');
        }
        messages.refresh();
      }
    } catch (_) {
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: 'failed');
      }
    }
  }

  Future<void> markRead() async {
    if (_sessionId == null) return;
    try {
      await _markMessagesReadUseCase.execute(_sessionId!);
    } catch (e) {
      debugPrint("Error marking messages read: $e");
    }
  }

  Future<void> endChatSession({bool skipSummary = false}) async {
    if (_sessionId == null) return;
    isLoading.value = true;
    try {
      final ChatSession? session;
      if (isPackageChat && SessionBottomSheetHelper.activeSubSessionId != null) {
        final response = await Get.find<ApiClient>().post(
          AppUrls.packageSessionEnd,
          data: {'sub_session_id': SessionBottomSheetHelper.activeSubSessionId},
        );
        if (response.isSuccess) {
          final data = response.body is Map<String, dynamic> ? response.body : {};
          final int duration = data['sub_session']?['duration_used'] ?? 0;
          session = ChatSession(
            id: _sessionId!,
            durationSeconds: duration,
            totalCost: 0.0,
          );
        } else {
          throw Exception(response.message);
        }
      } else {
        session = await _endChatSessionUseCase.execute(_sessionId!);
      }

      status.value = 'ended';
      _timer?.cancel();
      ForegroundTaskService.stopService();
      LocalNotificationService.cancelOngoingChatNotification(_sessionId!);
      FloatingChatBubble.dismiss();
      if (session != null) {
        WebSocketService.activeSessionId = null;
      }
    } catch (e) {
      CustomSnackbar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectChatSession() async {
    if (_sessionId == null) {
      Get.back();
      return;
    }
    final targetId = _sessionId!;
    _stopRingtone();
    status.value = 'ended';
    _timer?.cancel();
    ForegroundTaskService.stopService();
    LocalNotificationService.cancelOngoingChatNotification(targetId);
    FloatingChatBubble.dismiss();
    
    // Immediately close screen for smooth UX
    if (Get.isRegistered<ChatController>()) {
      Get.back();
    }

    try {
      await _rejectChatSessionUseCase.execute(targetId);
    } catch (e) {
      debugPrint("Error rejecting/cancelling chat session: $e");
    } finally {
      LocalNotificationService.cancelOngoingChatNotification(targetId);
      FloatingChatBubble.dismiss();
    }
  }

  void minimizeToBubble(BuildContext context, String name, String image, {bool shouldPop = true}) {
    debugPrint("==== [FLOATING_CHAT_DEBUG] ChatController.minimizeToBubble called! sessionId=$_sessionId, status=${status.value}, shouldPop=$shouldPop ====");
    if (_sessionId == null || (status.value != 'ongoing' && status.value != 'initiated')) {
      debugPrint("==== [FLOATING_CHAT_DEBUG] minimizeToBubble SKIPPED because sessionId is null or status invalid ====");
      return;
    }
    WebSocketService.activeSessionId = null;
    final startStr = _startedAt ?? WebSocketService.sessionStartTimes[_sessionId!] ?? DateTime.now().subtract(Duration(seconds: elapsedSeconds.value)).toIso8601String();
    WebSocketService.sessionStartTimes[_sessionId!] = startStr;

    FloatingChatBubble.show(
      context: context,
      sessionId: _sessionId!,
      name: name,
      imageUrl: image,
      startedAt: startStr,
      status: status.value,
      onTap: () {
        final currentStatus = FloatingChatBubble.chatStatus.value;
        debugPrint("==== [FLOATING_CHAT_DEBUG] FloatingChatBubble tapped! Navigating back to ChatScreen for sessionId=$_sessionId ====");
        FloatingChatBubble.dismiss(stopForegroundService: false);
        Get.to(
          () => ChatScreen(
            astrologerName: name,
            astrologerImage: image,
            sessionId: _sessionId!,
            initialStatus: currentStatus,
            startedAtString: startStr,
          ),
          binding: ChatBinding(),
        );
      },
    );
    if (shouldPop) {
      Navigator.of(context).pop();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _scrollListener() {
    // Implement scroll listener logic if needed
  }

  void _handlePackageTerminated() {
    status.value = 'ended';
    _timer?.cancel();
    ForegroundTaskService.stopService();
    if (_sessionId != null) {
      LocalNotificationService.cancelOngoingChatNotification(_sessionId!);
    }
    FloatingChatBubble.dismiss();
    WebSocketService.activeSessionId = null;
    
    Get.back();
    Get.dialog(
      AlertDialog(
        title: const Text("Session Expired"),
        content: const Text("Your prepaid package session has expired. Conversation has ended."),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    _stopRingtone();
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _msgSub?.cancel();
    _endSub?.cancel();
    _statusSub?.cancel();
    _statusUpdateSub?.cancel();
    _dismissSub?.cancel();
    _packageTerminatedSub?.cancel();
    
    // Only dismiss notification & bubble if session is actually ended/completed
    if (status.value == 'ended' || status.value == 'completed' || status.value == 'cancelled' || status.value == 'rejected') {
      if (_sessionId != null) {
        LocalNotificationService.cancelOngoingChatNotification(_sessionId!);
      } else {
        LocalNotificationService.cancelOngoingChatNotification(null);
      }
      FloatingChatBubble.dismiss(stopForegroundService: true);
      if (WebSocketService.activeSessionId == _sessionId) {
        WebSocketService.activeSessionId = null;
      }
    }
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
