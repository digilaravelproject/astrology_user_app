import 'package:astro_user/features/history/data/models/chat_session_model.dart';
import 'package:astro_user/features/call/data/models/call_session_model.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/services/network/response_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class HistoryRepository {
  Future<ChatSessionListResponse> getChatSessions({int page = 1});
  Future<CallSessionListResponse> getCallSessions({int page = 1});
}

class HistoryRepositoryImpl implements HistoryRepository {
  final ApiClient _apiClient;

  HistoryRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<ChatSessionListResponse> getChatSessions({int page = 1}) async {
    try {
      final response = await _apiClient.get('${AppUrls.userChatSessions}?page=$page');
      if (response.isSuccess && response.body != null) {
        return ChatSessionListResponse.fromJson(response.body);
      } else {
        throw Exception(response.message ?? 'Failed to fetch chat sessions');
      }
    } catch (e) {
      debugPrint('Error in HistoryRepository.getChatSessions: $e');
      rethrow;
    }
  }

  @override
  Future<CallSessionListResponse> getCallSessions({int page = 1}) async {
    try {
      final response = await _apiClient.get('${AppUrls.userCallSessions}?page=$page');
      if (response.isSuccess && response.body != null) {
        return CallSessionListResponse.fromJson(response.body);
      } else {
        throw Exception(response.message ?? 'Failed to fetch call sessions');
      }
    } catch (e) {
      debugPrint('Error in HistoryRepository.getCallSessions: $e');
      rethrow;
    }
  }
}

