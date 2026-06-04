import 'package:astro_user/features/history/domain/models/chat_session_model.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/services/network/response_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class HistoryRepository {
  Future<ChatSessionListResponse> getChatSessions({int page = 1});
}

class HistoryRepositoryImpl implements HistoryRepository {
  final ApiClient _apiClient;

  HistoryRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<ChatSessionListResponse> getChatSessions({int page = 1}) async {
    try {
      final response = await _apiClient.get('${AppUrls.userChatSessions}?page=$page');
      if (response.isSuccess && response.body != null) {
        final data = response.body['data'] ?? response.body;
        return ChatSessionListResponse.fromJson(data);
      } else {
        throw Exception(response.message ?? 'Failed to fetch chat sessions');
      }
    } catch (e) {
      debugPrint('Error in HistoryRepository.getChatSessions: $e');
      rethrow;
    }
  }
}
