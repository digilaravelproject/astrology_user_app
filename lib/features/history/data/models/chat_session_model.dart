import 'package:get/get.dart';
class ChatSessionListResponse {
  final int currentPage;
  final List<ChatSessionModel> data;

  ChatSessionListResponse({
    required this.currentPage,
    required this.data,
  });

  factory ChatSessionListResponse.fromJson(Map<String, dynamic> json) {
    return ChatSessionListResponse(
      currentPage: int.tryParse(json['current_page']?.toString() ?? '') ?? 1,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ChatSessionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ChatSessionModel {
  final int id;
  final int consumerId;
  final int providerId;
  final String status;
  final int ratePerMinute;
  final int durationSeconds;
  final num totalCost;
  final String createdAt;
  final String startedAt;
  final int unreadCount;
  
  // Either consumer or provider will be populated depending on the API side
  final ChatSessionUserModel? provider;
  final ChatSessionUserModel? consumer;
  
  final ChatSessionLatestMessage? latestMessage;

  ChatSessionModel({
    required this.id,
    required this.consumerId,
    required this.providerId,
    required this.status,
    required this.ratePerMinute,
    required this.durationSeconds,
    required this.totalCost,
    required this.createdAt,
    required this.startedAt,
    required this.unreadCount,
    this.provider,
    this.consumer,
    this.latestMessage,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      consumerId: int.tryParse(json['consumer_id']?.toString() ?? '') ?? 0,
      providerId: int.tryParse(json['provider_id']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? '',
      ratePerMinute: int.tryParse(json['rate_per_minute']?.toString() ?? '') ?? 0,
      durationSeconds: int.tryParse(json['duration_seconds']?.toString() ?? '') ?? 0,
      totalCost: num.tryParse(json['total_cost']?.toString() ?? '') ?? 0.0,
      createdAt: json['created_at']?.toString() ?? '',
      startedAt: json['started_at']?.toString() ?? '',
      unreadCount: int.tryParse(json['unread_count']?.toString() ?? '') ?? 0,
      provider: json['provider'] != null ? ChatSessionUserModel.fromJson(json['provider']) : null,
      consumer: json['consumer'] != null ? ChatSessionUserModel.fromJson(json['consumer']) : null,
      latestMessage: json['latest_message'] != null ? ChatSessionLatestMessage.fromJson(json['latest_message']) : null,
    );
  }
}

class ChatSessionUserModel {
  final int id;
  final String name;
  final String? profilePhoto;
  final int chatRatePerMinute;

  ChatSessionUserModel({
    required this.id,
    required this.name,
    this.profilePhoto,
    required this.chatRatePerMinute,
  });

  factory ChatSessionUserModel.fromJson(Map<String, dynamic> json) {
    int chatRate = 0;
    if (json['astrologer'] != null && json['astrologer']['chat_rate_per_minute'] != null) {
      chatRate = int.tryParse(json['astrologer']['chat_rate_per_minute'].toString()) ?? 0;
    }
    return ChatSessionUserModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      profilePhoto: json['astrologer']?['profile_photo']?.toString() ?? json['profile_photo']?.toString(),
      chatRatePerMinute: chatRate,
    );
  }
}

class ChatSessionLatestMessage {
  final int id;
  final int chatSessionId;
  final int senderId;
  final int receiverId;
  final String message;
  final String type;
  final String createdAt;

  ChatSessionLatestMessage({
    required this.id,
    required this.chatSessionId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.type,
    required this.createdAt,
  });

  factory ChatSessionLatestMessage.fromJson(Map<String, dynamic> json) {
    return ChatSessionLatestMessage(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      chatSessionId: int.tryParse(json['chat_session_id']?.toString() ?? '') ?? 0,
      senderId: int.tryParse(json['sender_id']?.toString() ?? '') ?? 0,
      receiverId: int.tryParse(json['receiver_id']?.toString() ?? '') ?? 0,
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
