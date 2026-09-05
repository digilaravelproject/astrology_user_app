import 'dart:async';
import 'package:get/get.dart';
import 'package:astro_user/core/utils/custom_snackbar.dart';
import 'package:astro_user/core/services/network/api_checker.dart';
import 'package:astro_user/features/live/data/models/live_session_model.dart';
import 'package:astro_user/features/live/domain/usecases/live_usecases.dart';

class LiveController extends GetxController {
  final GetActiveLiveSessionsUseCase _getActiveSessionsUseCase;
  final GetLiveSessionDetailUseCase _getSessionDetailUseCase;
  final JoinLiveSessionUseCase _joinSessionUseCase;
  final LeaveLiveSessionUseCase _leaveSessionUseCase;
  final SendLiveCommentUseCase _sendCommentUseCase;
  final SendSuperChatUseCase _sendSuperChatUseCase;
  final GetLiveCommentsUseCase _getCommentsUseCase;
  final WatchLiveSessionUseCase _watchSessionUseCase;

  LiveController(
    this._getActiveSessionsUseCase,
    this._getSessionDetailUseCase,
    this._joinSessionUseCase,
    this._leaveSessionUseCase,
    this._sendCommentUseCase,
    this._sendSuperChatUseCase,
    this._getCommentsUseCase,
    this._watchSessionUseCase,
  );


  final RxList<LiveSessionModel> activeSessions = <LiveSessionModel>[].obs;
  final Rx<LiveSessionModel?> currentSession = Rx<LiveSessionModel?>(null);
  final RxList<LiveCommentModel> comments = <LiveCommentModel>[].obs;
  final RxBool isCameraOn = true.obs;
  final RxBool isAudioOn = true.obs;
  
  final RxBool isLoadingSessions = false.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxBool isSendingComment = false.obs;
  final RxBool isSendingSuperChat = false.obs;
  
  Timer? _commentsPollTimer;

  Future<void> fetchActiveSessions() async {
    try {
      isLoadingSessions.value = true;
      final result = await _getActiveSessionsUseCase.call();
      if (result.isSuccess && result.body != null) {
        final List<dynamic> data;
        if (result.body is List) {
          data = result.body;
        } else if (result.body is Map) {
          data = result.body['data'] is List ? result.body['data'] : (result.body['body'] is List ? result.body['body'] : []);
        } else {
          data = [];
        }
        activeSessions.value = data.map((json) => LiveSessionModel.fromJson(json)).toList();
        print('[LIVE] Loaded ${activeSessions.length} active live sessions');
      }
    } catch (e) {
      print('[LIVE] Error fetching active sessions: $e');
    } finally {
      isLoadingSessions.value = false;
    }
  }

  void updateActiveSessionsFromEvent(dynamic rawData) {
    try {
      if (rawData != null && rawData['active_sessions'] is List) {
        final List<dynamic> data = rawData['active_sessions'];
        activeSessions.value = data.map((json) => LiveSessionModel.fromJson(json)).toList();
        print('[LIVE] Updated active live sessions from WS event. Count: ${activeSessions.length}');
      }
    } catch (e) {
      print('[LIVE] Error updating active sessions from WS event: $e');
    }
  }

  Future<void> fetchSessionDetail(int id) async {
    try {
      isLoadingDetail.value = true;
      final result = await _getSessionDetailUseCase.call(id);
      if (result.isSuccess && result.body != null) {
        final dynamic bodyData = result.body;
        if (bodyData is Map<String, dynamic>) {
          if (bodyData.containsKey('id') && bodyData.containsKey('title')) {
            currentSession.value = LiveSessionModel.fromJson(bodyData);
          } else if (bodyData['data'] is Map<String, dynamic>) {
            currentSession.value = LiveSessionModel.fromJson(bodyData['data']);
          }
        }
        if (currentSession.value != null) {
          isCameraOn.value = currentSession.value!.isCameraOn;
          isAudioOn.value = currentSession.value!.isAudioOn;
          if (!currentSession.value!.isBroadcasting) {
            isCameraOn.value = false;
            isAudioOn.value = false;
          }
        }
      }
    } catch (e) {
      print('[LIVE] Error fetching session detail: $e');
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> joinSession(int id) async {
    isCameraOn.value = true;
    isAudioOn.value = true;
    try {
      final result = await _joinSessionUseCase.call(id);
      if (result.isSuccess && result.body != null) {
        print('[LIVE] Successfully joined session $id');
        final dynamic body = result.body;
        if (body is Map<String, dynamic>) {
          final sessionData = body['session'] ?? body['data']?['session'] ?? body['data'];
          if (sessionData != null) {
            currentSession.value = LiveSessionModel.fromJson(sessionData);
            
            // Set initial camera/audio state
            isCameraOn.value = currentSession.value!.isCameraOn;
            isAudioOn.value = currentSession.value!.isAudioOn;
            if (!currentSession.value!.isBroadcasting) {
              isCameraOn.value = false;
              isAudioOn.value = false;
            }
          }
          
          final lastComments = body['last_comments'] ?? body['data']?['last_comments'];
          if (lastComments is List) {
            comments.value = lastComments.map((json) => LiveCommentModel.fromJson(json)).toList();
          }
        }
        
        // Start polling comments periodically
        _startCommentsPolling(id);
      }
    } catch (e) {
      print('[LIVE] Error joining session: $e');
    }
  }

  Future<void> leaveSession(int id) async {
    try {
      _stopCommentsPolling();
      final result = await _leaveSessionUseCase.call(id);
      if (result.isSuccess) {
        print('[LIVE] Successfully left session $id');
        currentSession.value = null;
        comments.clear();
      }
    } catch (e) {
      print('[LIVE] Error leaving session: $e');
    }
  }

  Future<void> fetchComments(int sessionId) async {
    try {
      final result = await _getCommentsUseCase.call(sessionId);
      if (result.isSuccess && result.body != null) {
        final List<dynamic> data;
        if (result.body is List) {
          data = result.body;
        } else if (result.body is Map) {
          final dynamic rawData = result.body['data'];
          if (rawData is List) {
            data = rawData;
          } else if (rawData is Map && rawData['data'] is List) {
            data = rawData['data'];
          } else {
            data = [];
          }
        } else {
          data = [];
        }
        final newComments = data.map((json) => LiveCommentModel.fromJson(json)).toList();
        
        comments.value = newComments;
      }
    } catch (e) {
      print('[LIVE] Error fetching comments: $e');
    }
  }

  Future<void> sendComment(int sessionId, String message) async {
    if (message.trim().isEmpty) return;
    try {
      isSendingComment.value = true;
      
      // Optimistic Update
      final tempComment = LiveCommentModel(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: 0,
        userName: 'You',
        message: message,
        createdAt: DateTime.now(),
      );
      comments.add(tempComment);

      final result = await _sendCommentUseCase.call(sessionId, message);
      if (result.isSuccess) {
        print('[LIVE] Comment sent successfully');
        // Fetch comments to sync ID
        await fetchComments(sessionId);
      } else {
        // Rollback optimistic update
        comments.removeWhere((c) => c.id == tempComment.id);
        CustomSnackbar.showError(result.message);
      }
    } catch (e) {
      print('[LIVE] Error sending comment: $e');
    } finally {
      isSendingComment.value = false;
    }
  }

  Future<bool> sendSuperChat(int sessionId, int giftId, String? message) async {
    try {
      isSendingSuperChat.value = true;
      final result = await _sendSuperChatUseCase.call(sessionId, giftId, message);
      if (result.isSuccess) {
        CustomSnackbar.showSuccess('Super Chat sent successfully! 🎉');
        await fetchComments(sessionId);
        return true;
      } else {
        CustomSnackbar.showError(result.message);
        return false;
      }
    } catch (e) {
      print('[LIVE] Error sending Super Chat: $e');
      CustomSnackbar.showError('Transaction failed: $e');
      return false;
    } finally {
      isSendingSuperChat.value = false;
    }
  }

  void _startCommentsPolling(int sessionId) {
    _stopCommentsPolling();
    fetchComments(sessionId);
    fetchSessionDetail(sessionId);
  }

  void _stopCommentsPolling() {
    _commentsPollTimer?.cancel();
    _commentsPollTimer = null;
  }

  Future<Map<String, dynamic>?> watchLiveSession(int id) async {
    try {
      final result = await _watchSessionUseCase.call(id);
      if (result.isSuccess && result.body != null) {
        final dynamic body = result.body;
        if (body is Map<String, dynamic>) {
          if (body['data'] is Map<String, dynamic>) {
            return body['data'];
          }
          return body;
        }
      } else {
        print('[LIVE] Watch token generation failed: ${result.message}');
      }
    } catch (e) {
      print('[LIVE] Error getting watch token: $e');
    }
    return null;
  }

  @override
  void onClose() {
    _stopCommentsPolling();
    super.onClose();
  }
}

