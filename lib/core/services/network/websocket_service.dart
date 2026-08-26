import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../../../features/live/data/models/live_session_model.dart';
import '../storage/token_manger.dart';
import '../storage/shared_prefs.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/domain/models/user_model.dart';
import 'api_client.dart';
import '../../../core/constants/app_urls.dart';
import '../../utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:astro_user/core/utils/custom_snackbar.dart';
import 'package:astro_user/features/chat/presentation/widgets/chat_summary_dialog.dart';
import 'package:astro_user/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_user/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_user/features/call/presentation/widgets/floating_call_bubble.dart';
import 'package:astro_user/core/services/local_notification_service.dart';
import 'package:astro_user/features/chat/presentation/controllers/chat_controller.dart';
import 'package:astro_user/features/chat/domain/usecases/sync_message_status_usecase.dart';
import 'package:astro_user/features/live/presentation/controllers/live_controller.dart';
import 'package:astro_user/features/chat_assistance/presentation/controllers/chat_assistance_controller.dart';
import 'package:astro_user/features/live/data/models/live_session_model.dart';
import 'package:astro_user/features/astrologers/controllers/astrologer_controller.dart';

class WebSocketService extends GetxService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _socketId;
  final Set<String> _subscribedChannels = {};
  int? _userId;
  String? _token;
  
  static int? activeSessionId;
  static final RxMap<int, String> sessionStatusUpdates = <int, String>{}.obs;
  static int? currentUserId;
  static final RxList<Map<String, dynamic>> incomingMessages = <Map<String, dynamic>>[].obs;
  static final RxList<Map<String, dynamic>> messageStatusUpdates = <Map<String, dynamic>>[].obs;
  static final RxList<Map<String, dynamic>> presenceUpdates = <Map<String, dynamic>>[].obs;
  static final RxMap<int, String> sessionStartTimes = <int, String>{}.obs;
  // Signal: when set to a sessionId, that chat session has been ended remotely
  static final RxInt chatEndedSessionId = (-1).obs;
  static final RxInt chatDismissedSessionId = (-1).obs;
  static final RxMap<String, dynamic> chatEndedBilling = <String, dynamic>{}.obs;

  // Call System State
  static final RxMap<int, String> callSessionStatusUpdates = <int, String>{}.obs;
  static final RxInt callEndedSessionId = (-1).obs;
  static final RxInt callDismissedSessionId = (-1).obs;
  static final RxMap<String, dynamic> callDismissedData = <String, dynamic>{}.obs;
  static final RxMap<String, dynamic> callAcceptedData = <String, dynamic>{}.obs;
  static final RxMap<String, dynamic> callEndedData = <String, dynamic>{}.obs;
  static final RxMap<String, dynamic> iceCandidateData = <String, dynamic>{}.obs;

  // Prepaid Package Session State
  static final RxInt packageRemainingSeconds = 0.obs;
  static final RxBool isPackageSessionTerminated = false.obs;

  final String _wsUrl = AppUrls.webSocketUrl;
  
  bool get isConnected => _isConnected;

  Future<WebSocketService> init() async {
    // We will wait until we actually have user data to connect
    return this;
  }

  /// Connects the websocket if user is logged in
  Future<void> connect() async {
    if (_isConnected || _isConnecting) return;
    _isConnecting = true;

    try {
      _token = await TokenManager.getToken();
      
      final userDataStr = SharedPrefs.getString(AppConstants.userData);
      if (userDataStr != null && userDataStr.isNotEmpty) {
         final userModel = UserModel.fromJsonString(userDataStr);
         _userId = userModel?.id;
         currentUserId = _userId;
      }

      if (_token == null || _token!.isEmpty || _userId == null) {
        Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        Logger.e('|🔌 WEBSOCKET ERROR');
        Logger.e('|⚠️ Cannot connect, token or userId is missing.');
        Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return;
      }

      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      Logger.d('|🔌 WEBSOCKET CONNECTING');
      Logger.d('|📍 URL: $_wsUrl');
      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      _channel = IOWebSocketChannel.connect(
        Uri.parse(_wsUrl),
        headers: {'Origin': 'https://suryapathkundli.com'},
      );
      
      _channel?.stream.listen(
        (message) {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📥 WEBSOCKET RECEIVED');
          Logger.d('|📨 Data: $message');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleMessage(message);
        },
        onDone: () {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔌 WEBSOCKET DISCONNECTED');
          Logger.d('|⚠️ Connection closed (onDone)');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _isConnecting = false;
          _isConnected = false;
          _socketId = null;
          _reconnect();
        },
        onError: (error) {
          Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.e('|🔌 WEBSOCKET ERROR');
          Logger.e('|⚠️ Exception: $error');
          Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _isConnecting = false;
          _isConnected = false;
          _socketId = null;
          _reconnect();
        },
      );
    } catch (e) {
      Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      Logger.e('|🔌 WEBSOCKET EXCEPTION');
      Logger.e('|⚠️ Exception: $e');
      Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      _isConnecting = false;
      _reconnect();
    }
  }

  void _handleMessage(dynamic message) {
    if (message is String) {
      try {
        final Map<String, dynamic> data = jsonDecode(message);
        final String? event = data['event'];
        
        if (event == AppUrls.pusherConnectionEstablished) {
          final String connectionDataStr = data['data'];
          final Map<String, dynamic> connectionData = jsonDecode(connectionDataStr);
          _socketId = connectionData['socket_id'];
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|✅ WEBSOCKET ESTABLISHED');
          Logger.d('|🔗 Socket ID: $_socketId');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _isConnecting = false;
          _isConnected = true;
          _authenticateAndSubscribe();
        } else if (event == AppUrls.pusherSubscriptionSucceeded) {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|✅ WEBSOCKET SUBSCRIPTION SUCCESS');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        } else if (event == AppUrls.eventChatAccepted || event == 'App\\Events\\ChatAccepted') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleChatAccepted(data['data']);
        } else if (event == AppUrls.eventChatEnded || event == 'App\\Events\\ChatEnded') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleChatEnded(data['data']);
        } else if (event == AppUrls.eventChatDismissed) {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleChatDismissed(data['data']);
        } else if (event == AppUrls.eventMessageSent || event == 'App\\Events\\MessageSent') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleMessageSent(data['data']);
        } else if (event == AppUrls.eventChatInitiated || event == 'App\\Events\\ChatInitiated') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        } else if (event == 'ChatQueueUpdated' || event == 'App\\Events\\ChatQueueUpdated') {
          // Server sends ChatQueueUpdated instead of ChatAccepted/ChatDismissed
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: ChatQueueUpdated');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          try {
            Map<String, dynamic> queueData = {};
            if (data['data'] is String) {
              queueData = jsonDecode(data['data'] as String);
            } else if (data['data'] is Map) {
              queueData = Map<String, dynamic>.from(data['data'] as Map);
            }
            final String action = queueData['action']?.toString() ?? '';
            if (action == 'accepted') {
              // Route to ChatAccepted handler using the session from payload
              final session = queueData['session'];
              if (session != null) {
                _handleChatAccepted({'session': session});
              }
            } else if (action == 'ended' || action == 'cancelled') {
              final session = queueData['session'];
              if (session != null) {
                _handleChatEnded({'session': session});
              }
            }
            // 'initiated' action is informational only — no action needed for user side
          } catch (e) {
            Logger.e('WebSocketService: Error handling ChatQueueUpdated -> $e');
          }
        } else if (event == AppUrls.eventMessageStatusUpdated || event == 'App\\Events\\MessageStatusUpdated') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleMessageStatusUpdated(data['data']);
        } else if (event == AppUrls.eventPresenceUpdated || event == 'App\\Events\\PresenceUpdated') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handlePresenceUpdated(data['data']);
        } else if (event == AppUrls.eventChatDismissed || event == 'App\\Events\\ChatDismissed') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleChatDismissed(data['data']);
        } else if (event == AppUrls.eventCallAccepted || event == 'App\\Events\\CallAccepted') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📞 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleCallAccepted(data['data']);
        } else if (event == AppUrls.eventCallDismissed || event == 'App\\Events\\CallDismissed') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📞 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleCallDismissed(data['data']);
        } else if (event == AppUrls.eventCallEnded || event == 'App\\Events\\CallEnded') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📞 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleCallEnded(data['data']);
        } else if (event == AppUrls.eventIceCandidateSent || event == 'App\\Events\\IceCandidateSent') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📞 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleIceCandidateSent(data['data']);
        } else if (event == AppUrls.pusherPing) {
           _send(AppUrls.pusherPong);
        } else if (event == AppUrls.eventLiveSessionStarted || event == 'App\\Events\\${AppUrls.eventLiveSessionStarted}' || event == '.${AppUrls.eventLiveSessionStarted}') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📺 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleLiveSessionStarted(data['data']);
        } else if (event == AppUrls.eventViewerCountUpdated || event == 'App\\Events\\${AppUrls.eventViewerCountUpdated}' || event == '.${AppUrls.eventViewerCountUpdated}') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📺 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleViewerCountUpdated(data['data']);
        } else if (event == AppUrls.eventNewLiveComment || event == 'App\\Events\\${AppUrls.eventNewLiveComment}' || event == '.${AppUrls.eventNewLiveComment}') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📺 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleNewLiveComment(data['data']);
        } else if (event == AppUrls.eventSuperChatReceived || event == 'App\\Events\\${AppUrls.eventSuperChatReceived}' || event == '.${AppUrls.eventSuperChatReceived}') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📺 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleSuperChatReceived(data['data']);
        } else if (event == AppUrls.eventLiveSessionEnded || event == 'App\\Events\\${AppUrls.eventLiveSessionEnded}' || event == '.${AppUrls.eventLiveSessionEnded}') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📺 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleLiveSessionEnded(data['data']);
        } else if (event == AppUrls.eventAstrologerBroadcastStarted || event == 'App\\Events\\${AppUrls.eventAstrologerBroadcastStarted}' || event == '.${AppUrls.eventAstrologerBroadcastStarted}') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📺 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleAstrologerBroadcastStarted(data['data']);
        } else if (event == AppUrls.eventAstrologerMediaStatusChanged || event == 'App\\Events\\${AppUrls.eventAstrologerMediaStatusChanged}' || event == '.${AppUrls.eventAstrologerMediaStatusChanged}') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📺 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleAstrologerMediaStatusChanged(data['data']);
        } else if (event == AppUrls.eventUserJoinedLiveSession || event == 'App\\Events\\${AppUrls.eventUserJoinedLiveSession}' || event == '.${AppUrls.eventUserJoinedLiveSession}') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📺 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleUserJoinedLiveSession(data['data']);
        } else if (event == AppUrls.eventUserLeftLiveSession || event == 'App\\Events\\${AppUrls.eventUserLeftLiveSession}' || event == '.${AppUrls.eventUserLeftLiveSession}') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📺 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleUserLeftLiveSession(data['data']);
        } else if (event == AppUrls.eventPackageSubSessionStarted || event == 'App\\Events\\${AppUrls.eventPackageSubSessionStarted}') {
          Logger.d('Prepaid Package session started: ${data['data']}');
          try {
            Map<String, dynamic> eventData = {};
            if (data['data'] is String) {
              eventData = jsonDecode(data['data'] as String);
            } else if (data['data'] is Map) {
              eventData = Map<String, dynamic>.from(data['data'] as Map);
            }
            final secs = eventData['remainingDuration'] ?? eventData['remaining_duration'] ?? eventData['subSession']?['purchase']?['remaining_duration'];
            packageRemainingSeconds.value = int.tryParse(secs?.toString() ?? '') ?? 0;
            isPackageSessionTerminated.value = false;
          } catch (e) {
            Logger.e('Error handling PackageSubSessionStarted -> $e');
          }
        } else if (event == AppUrls.eventPackageSubSessionEnded || event == 'App\\Events\\${AppUrls.eventPackageSubSessionEnded}') {
          Logger.d('Prepaid Package session ended: ${data['data']}');
          try {
            Map<String, dynamic> eventData = {};
            if (data['data'] is String) {
              eventData = jsonDecode(data['data'] as String);
            } else if (data['data'] is Map) {
              eventData = Map<String, dynamic>.from(data['data'] as Map);
            }
            final secs = eventData['remainingDuration'] ?? eventData['remaining_duration'] ?? eventData['subSession']?['purchase']?['remaining_duration'];
            packageRemainingSeconds.value = int.tryParse(secs?.toString() ?? '') ?? 0;
          } catch (e) {
            Logger.e('Error handling PackageSubSessionEnded -> $e');
          }
        } else if (event == AppUrls.eventPackageSessionTerminated || event == 'App\\Events\\${AppUrls.eventPackageSessionTerminated}') {
          Logger.d('Prepaid Package session terminated!');
          packageRemainingSeconds.value = 0;
          isPackageSessionTerminated.value = true;
        } else if (event == AppUrls.eventChatAssistanceMessageSent || event == 'App\\Events\\ChatAssistanceMessageSent') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleMessageSent(data['data']);
        } else if (event == AppUrls.eventChatAssistanceMessageStatusUpdated || event == 'App\\Events\\ChatAssistanceMessageStatusUpdated') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleMessageStatusUpdated(data['data']);
        } else if (event == AppUrls.eventChatAssistanceLimitReached || event == 'App\\Events\\ChatAssistanceLimitReached') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleChatAssistanceLimitReached(data['data']);
        } else if (event == 'AstrologerAvailabilityUpdated' || event == '.AstrologerAvailabilityUpdated' || event == 'App\\Events\\AstrologerAvailabilityUpdated') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: AstrologerAvailabilityUpdated');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleAstrologerAvailabilityUpdated(data['data']);
        }
      } catch (e) {
        Logger.e('WebSocketService: Error parsing message -> $e');
      }
    }
  }

  Future<void> subscribeToChannel(String channelName) async {
    _subscribedChannels.add(channelName);
    if (!_isConnected || _socketId == null) {
      Logger.d('Cannot subscribe to channel $channelName, not connected yet. Queued for later.');
      return;
    }
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(
        AppUrls.broadcastingAuth,
        data: {
          'channel_name': channelName,
          'socket_id': _socketId,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
        handleError: false,
        showErrorScreen: false,
      );

      final authString = response.body?['auth']?.toString();
      final channelData = response.body?['channel_data'];
      if (authString != null && authString.isNotEmpty) {
        Logger.d('Subscribing to dynamic channel: $channelName');
        final Map<String, dynamic> subscribeData = {
          "channel": channelName,
          "auth": authString
        };
        if (channelName.startsWith('presence-') && channelData != null) {
          subscribeData["channel_data"] = channelData is String ? channelData : jsonEncode(channelData);
        }
        _send(jsonEncode({
          "event": AppUrls.pusherSubscribe,
          "data": subscribeData
        }));
      }
    } catch (e) {
      Logger.e('Error subscribing to dynamic channel $channelName: $e');
    }
  }

  void unsubscribeFromChannel(String channelName) {
    _subscribedChannels.remove(channelName);
    if (_isConnected) {
      Logger.d('Unsubscribing from channel: $channelName');
      _send(jsonEncode({
        "event": "pusher:unsubscribe",
        "data": {
          "channel": channelName
        }
      }));
    }
  }

  void _handleAstrologerAvailabilityUpdated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      
      final int astroId = eventData['astrologer_id'] ?? 0;
      final bool isBusy = eventData['is_busy'] == true || eventData['is_busy'] == 1;
      final bool isOnline = eventData['is_online'] == true || eventData['is_online'] == 1;
      final String availabilityStatus = eventData['availability_status'] ?? 'Offline';

      if (Get.isRegistered<AstrologerController>() && astroId > 0) {
        Get.find<AstrologerController>().updateAstrologerAvailability(
          astrologerId: astroId,
          isOnline: isOnline,
          isBusy: isBusy,
          availabilityStatus: availabilityStatus,
        );
      }
    } catch (e) {
      Logger.e('WebSocketService: error handling AstrologerAvailabilityUpdated -> $e');
    }
  }

  void _handleLiveSessionStarted(dynamic rawData) {
    try {
      if (Get.isRegistered<LiveController>()) {
        Get.find<LiveController>().fetchActiveSessions();
      }
    } catch (e) {
      Logger.e('WebSocketService: error handling LiveSessionStarted -> $e');
    }
  }

  void _handleViewerCountUpdated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      final int sessionId = eventData['live_session_id'] is int 
          ? eventData['live_session_id'] 
          : (int.tryParse(eventData['live_session_id']?.toString() ?? '') ?? 0);
      final int count = eventData['viewer_count'] is int 
          ? eventData['viewer_count'] 
          : (int.tryParse(eventData['viewer_count']?.toString() ?? '') ?? 0);
      
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
      Logger.e('WebSocketService: error handling ViewerCountUpdated -> $e');
    }
  }

  void _handleNewLiveComment(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final int id = eventData['id'] is int 
          ? eventData['id'] 
          : (int.tryParse(eventData['id']?.toString() ?? '') ?? DateTime.now().millisecondsSinceEpoch);
      final int userId = eventData['user_id'] is int 
          ? eventData['user_id'] 
          : (int.tryParse(eventData['user_id']?.toString() ?? '') ?? 0);
      final String userName = eventData['user_name'] ?? 'User';
      final String? userAvatar = eventData['user_avatar'] ?? eventData['user_image'];
      final String message = eventData['message'] ?? '';
      final DateTime createdAt = eventData['created_at'] != null 
          ? DateTime.tryParse(eventData['created_at']) ?? DateTime.now() 
          : DateTime.now();

      // Backend uses toOthers() - sender doesn't receive this event
      // But add safety check in case
      if (userId == currentUserId) {
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
      Logger.e('WebSocketService: error handling NewLiveComment -> $e');
    }
  }

  void _handleSuperChatReceived(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      
      final String userName = eventData['user_name'] ?? 'User';
      final String giftTitle = eventData['gift'] != null ? eventData['gift']['title'] ?? 'Gift' : 'Gift';
      
      if (Get.isRegistered<LiveController>()) {
        final controller = Get.find<LiveController>();
        final newComment = LiveCommentModel(
          id: DateTime.now().millisecondsSinceEpoch,
          userId: eventData['user_id'] is int ? eventData['user_id'] : 0,
          userName: userName,
          userAvatar: eventData['user_avatar'],
          giftIconUrl: eventData['gift'] != null ? eventData['gift']['icon_url'] : null,
          message: 'Sent a $giftTitle',
          createdAt: DateTime.now(),
        );
        controller.comments.add(newComment);
      }
    } catch (e) {
      Logger.e('WebSocketService: error handling SuperChatReceived -> $e');
    }
  }

  void _handleAstrologerBroadcastStarted(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      
      final int sessionId = eventData['live_session_id'] is int 
          ? eventData['live_session_id'] 
          : (int.tryParse(eventData['live_session_id']?.toString() ?? '') ?? 0);
      
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
      Logger.e('WebSocketService: error handling AstrologerBroadcastStarted -> $e');
    }
  }

  void _handleAstrologerMediaStatusChanged(dynamic rawData) {
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
      Logger.e('WebSocketService: error handling AstrologerMediaStatusChanged -> $e');
    }
  }

  void _handleUserJoinedLiveSession(dynamic rawData) {
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
      Logger.e('WebSocketService: error handling UserJoinedLiveSession -> $e');
    }
  }

  void _handleUserLeftLiveSession(dynamic rawData) {
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
      Logger.e('WebSocketService: error handling UserLeftLiveSession -> $e');
    }
  }

  void _handleLiveSessionEnded(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      
      final int sessionId = eventData['session_id'] is int 
          ? eventData['session_id'] 
          : (int.tryParse(eventData['session_id']?.toString() ?? '') ?? 
            (eventData['id'] is int ? eventData['id'] : (int.tryParse(eventData['id']?.toString() ?? '') ?? 0)));
      
      if (Get.isRegistered<LiveController>()) {
        final controller = Get.find<LiveController>();
        if (sessionId == 0 || controller.currentSession.value?.id == sessionId) {
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
      Logger.e('WebSocketService: error handling LiveSessionEnded -> $e');
    }
  }

  Future<void> _authenticateAndSubscribe() async {
    if (_socketId == null || _userId == null) return;

    final Set<String> channelsToSubscribe = {
      AppUrls.privateUserChannel(_userId!),
      AppUrls.presenceRoomChannel,
      'astrologers',
      ..._subscribedChannels,
    };

    for (String channelName in channelsToSubscribe) {
      if (!channelName.startsWith('private-') && !channelName.startsWith('presence-')) {
        Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        Logger.d('|✅ WEBSOCKET PUBLIC CHANNEL SUBSCRIPTION');
        Logger.d('|📺 Channel: $channelName');
        Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        _send(jsonEncode({
          "event": AppUrls.pusherSubscribe,
          "data": { "channel": channelName }
        }));
        continue;
      }

      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      Logger.d('|🔐 WEBSOCKET AUTHENTICATING');
      Logger.d('|📺 Channel: $channelName');
      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      try {
        final apiClient = Get.find<ApiClient>();
        
        final response = await apiClient.post(
          AppUrls.broadcastingAuth,
          data: {
            'channel_name': channelName,
            'socket_id': _socketId,
          },
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
          ),
          handleError: false,
          showErrorScreen: false,
        );

        // broadcasting/auth returns {"auth": "..."} not standard format
        // so check body['auth'] directly, not response.isSuccess
        final authString = response.body?['auth']?.toString();
        final channelData = response.body?['channel_data'];
        
        if (authString != null && authString.isNotEmpty) {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|✅ WEBSOCKET AUTH SUCCESS');
          Logger.d('|🔑 Channel: $channelName');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

          final Map<String, dynamic> subscribeData = {
            "channel": channelName,
            "auth": authString
          };
          if (channelName.startsWith('presence-') && channelData != null) {
            subscribeData["channel_data"] = channelData is String ? channelData : jsonEncode(channelData);
          }
          
          _send(jsonEncode({
            "event": AppUrls.pusherSubscribe,
            "data": subscribeData
          }));
        } else {
          Logger.e('|❌ WEBSOCKET AUTH FAILED for $channelName, body=${response.body}');
        }
      } catch (e) {
        Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        Logger.e('|❌ WEBSOCKET AUTH EXCEPTION');
        Logger.e('|⚠️ Channel: $channelName, Error: $e');
        Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }
    }
  }

  void _send(String data) {
    if (_channel != null && _isConnected) {
      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      Logger.d('|📤 WEBSOCKET SENT');
      Logger.d('|📦 Data: $data');
      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      _channel!.sink.add(data);
    }
  }

  void _reconnect() {
    Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    Logger.d('|⏱️ WEBSOCKET RECONNECTING');
    Logger.d('|⚠️ Attempting to reconnect in 5 seconds...');
    Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    Future.delayed(const Duration(seconds: 5), () {
      connect();
    });
  }

  void disconnect() {
    Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    Logger.d('|🔌 WEBSOCKET DISCONNECTING');
    Logger.d('|⚠️ Client manually closing connection.');
    Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _isConnected = false;
    _socketId = null;
    _subscribedChannels.clear();
    _channel?.sink.close();
    _channel = null;
  }

  void _handleChatAccepted(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final session = eventData['session'];
      if (session == null) return;

      final int sessionId = session['id'] is int 
          ? session['id'] 
          : (int.tryParse(session['id']?.toString() ?? '') ?? 0);
      final String? startedAt = session['started_at']?.toString();
      if (startedAt != null) {
        sessionStartTimes[sessionId] = startedAt;
      }
      sessionStatusUpdates[sessionId] = 'ongoing';
      sessionStatusUpdates.refresh();

      // Update FloatingChatBubble status directly!
      if (FloatingChatBubble.isActive && FloatingChatBubble.sessionId == sessionId) {
        FloatingChatBubble.updateStatus('ongoing');

        // Show ongoing local notification since user minimized the chat and it just started!
        int? startedAtMillis;
        if (startedAt != null && startedAt.isNotEmpty) {
          String isoUtc = startedAt.trim().replaceAll(' ', 'T');
          if (!isoUtc.endsWith('Z') && !isoUtc.contains('+') && !isoUtc.contains('-')) {
            isoUtc += 'Z';
          }
          startedAtMillis = DateTime.tryParse(isoUtc)?.toLocal().millisecondsSinceEpoch;
        }
        LocalNotificationService.showOngoingChatNotification(
          sessionId: sessionId,
          title: '${FloatingChatBubble.name ?? "Astrologer"} • Chat',
          body: 'Ongoing chat session',
          startedAtMillis: startedAtMillis,
        );
      }

      // Update ChatController directly if registered
      if (Get.isRegistered<ChatController>()) {
        final controller = Get.find<ChatController>();
        if (controller.sessionId == sessionId) {
          controller.status.value = 'ongoing';
        }
      }
    } catch (e) {
      Logger.e('WebSocketService: error handling ChatAccepted -> $e');
    }
  }

  void _handleChatEnded(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final session = eventData['session'];
      if (session == null) return;

      final int sessionId = session['id'] is int 
          ? session['id'] 
          : (int.tryParse(session['id']?.toString() ?? '') ?? 0);
      final int durationSeconds = session['duration_seconds'] is int 
          ? session['duration_seconds'] 
          : (int.tryParse(session['duration_seconds']?.toString() ?? '') ?? 0);
      final double totalCost = double.tryParse(session['total_cost']?.toString() ?? '') ?? 0.0;

      Logger.d('WebSocketService: ChatEnded for sessionId=$sessionId, active=$activeSessionId');

      // Cancel notification & floating bubble immediately
      LocalNotificationService.cancelOngoingChatNotification(sessionId);
      FloatingChatBubble.dismiss(stopForegroundService: true);

      if (activeSessionId == sessionId) {
        activeSessionId = null;
      }
      chatEndedSessionId.value = sessionId;
    } catch (e) {
      Logger.e('WebSocketService: error handling ChatEnded -> $e');
    }
  }

  void _handleChatDismissed(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final session = eventData['session'];
      if (session == null) return;

      final int sessionId = session['id'];
      Logger.d('WebSocketService: ChatDismissed for sessionId=$sessionId');

      // Cancel notification & floating bubble immediately
      LocalNotificationService.cancelOngoingChatNotification(sessionId);
      FloatingChatBubble.dismiss(stopForegroundService: true);

      // Propagate the ended/dismissed status so ChatScreen / ChatController can react
      sessionStatusUpdates[sessionId] = 'ended';
      sessionStatusUpdates.refresh();

      // Always signal that this session was dismissed
      chatDismissedSessionId.value = sessionId;

      // If active screen is open, clear it
      if (activeSessionId == sessionId) {
        activeSessionId = null;
      }
    } catch (e) {
      Logger.e('WebSocketService: error handling ChatDismissed -> $e');
    }
  }

  void _handleMessageSent(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final messageData = eventData['messageData'];
      if (messageData != null) {
        final map = Map<String, dynamic>.from(messageData);
        incomingMessages.add(map);

        final int senderId = int.tryParse(map['sender_id']?.toString() ?? '') ?? 0;
        final int sessionId = int.tryParse(map['chat_assistance_session_id']?.toString() ?? map['chat_session_id']?.toString() ?? '') ?? 0;

        if (senderId != currentUserId && activeSessionId != sessionId) {
          if (FloatingChatBubble.isActive && FloatingChatBubble.sessionId == sessionId) {
            FloatingChatBubble.incrementUnreadCount();
          }
          _showInAppNotification(map);
          
          final int messageId = int.tryParse(map['id']?.toString() ?? '') ?? 0;
          if (messageId > 0 && Get.isRegistered<SyncMessageStatusUseCase>()) {
            Get.find<SyncMessageStatusUseCase>().execute(
              sessionId: sessionId,
              messageIds: [messageId],
              status: 'delivered',
            ).catchError((e) {
              debugPrint('Error syncing message status: $e');
            });
          }
        }
      }
    } catch (e) {
      Logger.e('WebSocketService: error handling MessageSent -> $e');
    }
  }

  void _showInAppNotification(Map<String, dynamic> msg) {
    final int sessionId = int.tryParse(msg['chat_session_id']?.toString() ?? '') ?? 0;
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
          Get.to(() => ChatScreen(
            astrologerName: "Astrologer",
            astrologerImage: "",
            sessionId: sessionId,
            initialStatus: 'ongoing',
          ));
        },
      );
    } catch (e) {
      Logger.e('WebSocketService: error showing snackbar -> $e');
    }
  }

  void _handleMessageStatusUpdated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      messageStatusUpdates.add(eventData);
    } catch (e) {
      Logger.e('WebSocketService: error handling MessageStatusUpdated -> $e');
    }
  }

  void _handlePresenceUpdated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      presenceUpdates.add(eventData);
    } catch (e) {
      Logger.e('WebSocketService: error handling PresenceUpdated -> $e');
    }
  }

  void _handleCallAccepted(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      final session = eventData['session'];
      if (session != null) {
        final int sessionId = session['id'] is int 
            ? session['id'] 
            : (int.tryParse(session['id']?.toString() ?? '') ?? 0);
        callSessionStatusUpdates[sessionId] = 'ongoing';
        callSessionStatusUpdates.refresh();
      }
      callAcceptedData.value = eventData;
      callAcceptedData.refresh();
    } catch (e) {
      Logger.e('WebSocketService: error handling CallAccepted -> $e');
    }
  }

  void _handleCallDismissed(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      final session = eventData['session'];
      if (session != null) {
        final int sessionId = session['id'] is int 
            ? session['id'] 
            : (int.tryParse(session['id']?.toString() ?? '') ?? 0);
        final String? reason = eventData['reason']?.toString();
        callSessionStatusUpdates[sessionId] = reason ?? 'dismissed';
        callSessionStatusUpdates.refresh();
        callDismissedSessionId.value = sessionId;
      }
      callDismissedData.value = eventData;
      callDismissedData.refresh();
    } catch (e) {
      Logger.e('WebSocketService: error handling CallDismissed -> $e');
    }
  }

  void _handleCallEnded(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      final session = eventData['session'];
      final int sessionId = session != null && session['id'] != null
          ? (session['id'] is int ? session['id'] : (int.tryParse(session['id']?.toString() ?? '') ?? 0))
          : 0;

      // Cancel call notifications & bubbles immediately
      LocalNotificationService.cancelOngoingCallNotification(sessionId);
      FloatingCallBubble.dismiss(stopForegroundService: true);

      if (sessionId != 0) {
        callSessionStatusUpdates[sessionId] = 'completed';
        callSessionStatusUpdates.refresh();
        callEndedSessionId.value = sessionId;
      }
      callEndedData.value = eventData;
      callEndedData.refresh();
    } catch (e) {
      Logger.e('WebSocketService: error handling CallEnded -> $e');
    }
  }

  void _handleIceCandidateSent(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      iceCandidateData.value = eventData;
      iceCandidateData.refresh();
    } catch (e) {
      Logger.e('WebSocketService: error handling IceCandidateSent -> $e');
    }
  }

  void _handleChatAssistanceLimitReached(dynamic rawData) {
    try {
      if (Get.isRegistered<ChatAssistanceController>()) {
        Get.find<ChatAssistanceController>().limitReached.value = true;
      }
    } catch (e) {
      Logger.e('WebSocketService: error handling ChatAssistanceLimitReached -> $e');
    }
  }
}
