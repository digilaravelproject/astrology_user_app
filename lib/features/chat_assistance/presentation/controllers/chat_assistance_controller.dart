import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/services/network/websocket_service.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/features/chat/domain/entities/chat_message.dart';
import 'package:astro_user/core/utils/custom_snackbar.dart';
import 'package:astro_user/features/auth/domain/models/user_model.dart';
import 'package:astro_user/core/services/storage/shared_prefs.dart';
import 'package:astro_user/core/constants/app_constants.dart';
import 'package:astro_user/features/chat_assistance/presentation/pages/chat_assistance_screen.dart';

class ChatAssistanceController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isInitiating = false.obs;
  final RxBool limitReached = false.obs;
  
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  int? _sessionId;
  int? _currentUserId;
  String? astrologerName;
  String? astrologerImage;

  StreamSubscription? _msgSub;
  StreamSubscription? _statusUpdateSub;
  StreamSubscription? _limitReachedSub;

  int? get sessionId => _sessionId;

  @override
  void onInit() {
    super.onInit();
    _currentUserId = WebSocketService.currentUserId;
    if (_currentUserId == null || _currentUserId == 0) {
      try {
        final userDataStr = SharedPrefs.getString(AppConstants.userData);
        if (userDataStr != null && userDataStr.isNotEmpty) {
          final userModel = UserModel.fromJsonString(userDataStr);
          _currentUserId = userModel?.id;
        }
      } catch (_) {}
    }
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Handle pagination if needed
  }

  Future<void> initiateChatAssistance(int providerId, {int? callSessionId, required String astroName, required String astroImage}) async {
    isInitiating.value = true;
    astrologerName = astroName;
    astrologerImage = astroImage;
    try {
      final body = {
        'provider_id': providerId,
        if (callSessionId != null) 'call_session_id': callSessionId,
      };

      final response = await _apiClient.post(AppUrls.initiateChatAssistance, data: body);
      
      if (response.isSuccess) {
        final data = response.body['data'];
        final session = data['session'];
        if (session != null) {
          _sessionId = session['id'];
          
          // Clear previous messages and fetch history
          messages.clear();
          await fetchMessages();

          // Listen to events
          _setupWebsocketListeners();

          // Navigate to Chat Assistance Screen
          Get.to(() => const ChatAssistanceScreen());
        }
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to initiate chat assistance: $e');
    } finally {
      isInitiating.value = false;
    }
  }

  Future<void> fetchMessages() async {
    if (_sessionId == null) return;
    isLoading.value = true;
    try {
      final response = await _apiClient.get(AppUrls.getChatAssistanceMessages(_sessionId!));
      if (response.isSuccess) {
        final data = response.body['data']['data'] as List;
        messages.assignAll(data.map((msg) {
          final int senderId = int.tryParse(msg['sender_id']?.toString() ?? '') ?? 0;
          final bool isMe = senderId == _currentUserId;
          return ChatMessage(
            id: int.tryParse(msg['id']?.toString() ?? '') ?? 0,
            text: msg['message']?.toString() ?? '',
            isMe: isMe,
            time: DateTime.tryParse(msg['created_at']?.toString() ?? '') ?? DateTime.now(),
            status: msg['is_read'] == true ? 'seen' : (msg['is_delivered'] == true ? 'delivered' : 'sent'),
            type: msg['type']?.toString() ?? 'text',
            attachmentUrl: msg['attachment_url']?.toString(),
            image: msg['type'] == 'image' ? msg['attachment_url']?.toString() : null,
          );
        }).toList().reversed);
        _scrollToBottom();
        syncReadStatus();
      }
    } catch (e) {
      print('Error fetching chat assistance messages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || _sessionId == null || limitReached.value) return;

    messageController.clear();

    final tempId = DateTime.now().millisecondsSinceEpoch;
    final localMsg = ChatMessage(
      id: tempId,
      text: text,
      isMe: true,
      time: DateTime.now(),
      status: 'sending...',
      type: 'text',
    );
    messages.insert(0, localMsg); // Assuming reversed list for chat
    _scrollToBottom();

    try {
      final body = {
        'message': text,
        'type': 'text',
      };
      
      final response = await _apiClient.post(AppUrls.sendChatAssistanceMessage(_sessionId!), data: body);
      
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        if (response.isSuccess) {
          final data = response.body['data']['message'];
          final serverId = data['id'];
          messages[index] = messages[index].copyWith(id: serverId, status: 'sent');
        } else {
          messages[index] = messages[index].copyWith(status: 'failed');
          if (response.message.toLowerCase().contains('limit')) {
            limitReached.value = true;
          }
        }
        messages.refresh();
      }
    } catch (e) {
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: 'failed');
        messages.refresh();
      }
    }
  }

  Future<void> syncReadStatus() async {
    if (_sessionId == null) return;
    
    // Find unread messages not from me
    final unreadIds = messages
        .where((m) => !m.isMe && (m.status != 'seen'))
        .map((m) => m.id)
        .toList();
        
    if (unreadIds.isEmpty) return;

    try {
      final body = {
        'status': 'seen',
        'message_ids': unreadIds,
      };
      await _apiClient.post(AppUrls.syncChatAssistanceStatus(_sessionId!), data: body);
      
      // Update local status
      for (int i = 0; i < messages.length; i++) {
        if (unreadIds.contains(messages[i].id)) {
          messages[i] = messages[i].copyWith(status: 'seen');
        }
      }
      messages.refresh();
    } catch (e) {
      print('Error syncing read status: $e');
    }
  }

  void _setupWebsocketListeners() {
    _msgSub?.cancel();
    _msgSub = WebSocketService.incomingMessages.listen((list) {
      if (list.isNotEmpty) {
        final lastMsg = list.last;
        final msgSessionId = int.tryParse(lastMsg['chat_assistance_session_id']?.toString() ?? '') ?? 0;
        if (msgSessionId == _sessionId) {
          final int senderId = int.tryParse(lastMsg['sender_id']?.toString() ?? '') ?? 0;
          final bool isMe = senderId == _currentUserId;

          final int msgId = int.tryParse(lastMsg['id']?.toString() ?? '') ?? 0;
          final alreadyExists = messages.any((m) => m.id == msgId);
          if (!alreadyExists) {
            messages.insert(0, ChatMessage(
              id: msgId,
              text: lastMsg['message']?.toString() ?? '',
              isMe: isMe,
              time: DateTime.tryParse(lastMsg['created_at']?.toString() ?? '') ?? DateTime.now(),
              status: 'delivered', 
              type: lastMsg['type']?.toString() ?? 'text',
              attachmentUrl: lastMsg['attachment_url']?.toString(),
              image: lastMsg['type'] == 'image' ? lastMsg['attachment_url']?.toString() : null,
            ));
            _scrollToBottom();
            syncReadStatus();
          }
        }
      }
    });

    _statusUpdateSub?.cancel();
    _statusUpdateSub = WebSocketService.messageStatusUpdates.listen((list) {
      if (list.isNotEmpty) {
        final lastUpdate = list.last;
        final updateSessionId = int.tryParse(lastUpdate['sessionId']?.toString() ?? '') ?? 0;
        if (updateSessionId == _sessionId) {
          final newStatus = lastUpdate['status']?.toString();
          final messageIdsList = lastUpdate['messageIds'] as List<dynamic>?;
          if (newStatus != null && messageIdsList != null && messageIdsList.isNotEmpty) {
             final messageIds = messageIdsList.map((e) => int.tryParse(e.toString()) ?? 0).toList();
             bool changed = false;
             for (int i = 0; i < messages.length; i++) {
               if (messageIds.contains(messages[i].id)) {
                 if (messages[i].status != 'seen') {
                   messages[i] = messages[i].copyWith(status: newStatus);
                   changed = true;
                 }
               }
             }
             if (changed) messages.refresh();
          }
        }
      }
    });
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

  @override
  void onClose() {
    _msgSub?.cancel();
    _statusUpdateSub?.cancel();
    _limitReachedSub?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
