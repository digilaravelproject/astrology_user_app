import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import 'package:astro_user/core/services/storage/token_manger.dart';
import 'package:astro_user/core/services/storage/shared_prefs.dart';
import 'package:astro_user/core/constants/app_constants.dart';
import 'package:astro_user/features/auth/data/models/user_model.dart';
import '../network/api_client.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/utils/logger.dart';
import 'package:flutter/material.dart';


import 'package:astro_user/core/services/websocket/router/websocket_event_router.dart';
import 'websocket_state.dart';

class WebSocketService extends GetxService with WidgetsBindingObserver {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isManuallyDisconnected = false;
  String? _socketId;
  final Set<String> _subscribedChannels = {};
  int? _userId;
  String? _token;
  
  // Heartbeat & Watchdog
  Timer? _heartbeatTimer;
  Timer? _pongTimeoutTimer;
  static const Duration _heartbeatInterval = Duration(seconds: 25);
  static const Duration _pongTimeout = Duration(seconds: 10);

  // Auto-reconnect & Backoff
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  StreamSubscription? _connectivitySubscription;
  final List<String> _offlineQueue = [];
  
  // ─── State Forwarding Shims ────────────────────────────────────────────────
  // All reactive state now lives in WebSocketState.
  // These shims keep existing code (WebSocketService.xxx) compiling unchanged.

  static int? get activeSessionId => WebSocketState.activeSessionId;
  static set activeSessionId(int? v) => WebSocketState.activeSessionId = v;

  static int? get currentUserId => WebSocketState.currentUserId;
  static set currentUserId(int? v) => WebSocketState.currentUserId = v;

  static Map<int, String> get sessionStartTimes => WebSocketState.sessionStartTimes;

  // Chat
  static RxInt get currentPingMs => WebSocketState.currentPingMs;
  static RxMap<int, String> get sessionStatusUpdates => WebSocketState.sessionStatusUpdates;
  static RxList<Map<String, dynamic>> get incomingMessages => WebSocketState.incomingMessages;
  static RxList<Map<String, dynamic>> get messageStatusUpdates => WebSocketState.messageStatusUpdates;
  static RxList<Map<String, dynamic>> get presenceUpdates => WebSocketState.presenceUpdates;
  static RxInt get chatEndedSessionId => WebSocketState.chatEndedSessionId;
  static RxInt get chatDismissedSessionId => WebSocketState.chatDismissedSessionId;
  static RxMap<String, dynamic> get chatEndedBilling => WebSocketState.chatEndedBilling;

  // Call
  static RxMap<int, String> get callSessionStatusUpdates => WebSocketState.callSessionStatusUpdates;
  static RxInt get callEndedSessionId => WebSocketState.callEndedSessionId;
  static RxInt get callDismissedSessionId => WebSocketState.callDismissedSessionId;
  static RxMap<String, dynamic> get callAcceptedData => WebSocketState.callAcceptedData;
  static RxMap<String, dynamic> get callDismissedData => WebSocketState.callDismissedData;
  static RxMap<String, dynamic> get callEndedData => WebSocketState.callEndedData;
  static RxMap<String, dynamic> get iceCandidateData => WebSocketState.iceCandidateData;

  // Package
  static RxInt get packageRemainingSeconds => WebSocketState.packageRemainingSeconds;
  static RxBool get isPackageSessionTerminated => WebSocketState.isPackageSessionTerminated;

  final String _wsUrl = AppUrls.webSocketUrl;
  
  bool get isConnected => _isConnected;

  Future<WebSocketService> init() async {
    WidgetsBinding.instance.addObserver(this);
    _setupConnectivityListener();
    return this;
  }

  void _setupConnectivityListener() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final isConnected = results.any((r) => r != ConnectivityResult.none);
      final isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
      if (isConnected && !_isConnected && !_isConnecting && !_isManuallyDisconnected && isLoggedIn) {
        Logger.d('|🌐 Connectivity restored! Triggering immediate WebSocket reconnect.');
        _reconnectAttempts = 0;
        connect();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
      if (!_isManuallyDisconnected && isLoggedIn) {
        Logger.d('|📱 App resumed from background/sleep. Checking WebSocket health...');
        if (!_isConnected && !_isConnecting) {
          _reconnectAttempts = 0;
          connect();
        } else if (_isConnected) {
          _sendHeartbeat();
        }
      }
    }
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_isConnected && _channel != null) {
        _sendHeartbeat();
      }
    });
  }

  DateTime? _lastPingSentAt;

  void _sendHeartbeat() {
    try {
      _pongTimeoutTimer?.cancel();
      _pongTimeoutTimer = Timer(_pongTimeout, () {
        Logger.w('|⚠️ WebSocket pong timeout! Socket is unresponsive. Forcing reconnect...');
        _forceDisconnectAndReconnect();
      });
      _lastPingSentAt = DateTime.now();
      _sendRaw(jsonEncode({
        "event": AppUrls.pusherPing,
        "data": {}
      }));
    } catch (e) {
      Logger.e('|⚠️ Error sending heartbeat ping: $e');
    }
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _pongTimeoutTimer?.cancel();
    _pongTimeoutTimer = null;
  }

  void _forceDisconnectAndReconnect() {
    _isConnecting = false;
    _isConnected = false;
    _socketId = null;
    _stopHeartbeat();
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _reconnect();
  }

  /// Connects the websocket if user is logged in
  Future<void> connect({bool isExplicitUserLogin = false}) async {
    if (isExplicitUserLogin) {
      _isManuallyDisconnected = false;
    }
    final bool isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
    if (!isLoggedIn || _isManuallyDisconnected) {
      _isConnecting = false;
      _isConnected = false;
      return;
    }
    if (_isConnected || _isConnecting) return;
    _isConnecting = true;
    _reconnectTimer?.cancel();

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
        _isConnecting = false;
        return;
      }

      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      Logger.d('|🔌 WEBSOCKET CONNECTING (Attempt: ${_reconnectAttempts + 1})');
      Logger.d('|📍 URL: $_wsUrl');
      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      _channel = IOWebSocketChannel.connect(
        Uri.parse(_wsUrl),
        headers: {'Origin': 'https://suryapathkundli.com'},
      );
      
      _channel?.stream.listen(
        (message) {
          _pongTimeoutTimer?.cancel();
          _handleMessage(message);
        },
        onDone: () {
          final wasConnected = _isConnected || _isConnecting;
          _isConnecting = false;
          _isConnected = false;
          _socketId = null;
          _stopHeartbeat();
          if (!_isManuallyDisconnected && wasConnected) {
            final loggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
            if (loggedIn) {
              Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
              Logger.d('|🔌 WEBSOCKET DISCONNECTED');
              Logger.d('|⚠️ Connection closed (onDone)');
              Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
              _reconnect();
            }
          }
        },
        onError: (error) {
          final wasConnected = _isConnected || _isConnecting;
          _isConnecting = false;
          _isConnected = false;
          _socketId = null;
          _stopHeartbeat();
          if (!_isManuallyDisconnected && wasConnected) {
            final loggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
            if (loggedIn) {
              Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
              Logger.e('|🔌 WEBSOCKET ERROR');
              Logger.e('|⚠️ Exception: $error');
              Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
              _reconnect();
            }
          }
        },
      );
    } catch (e) {
      Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      Logger.e('|🔌 WEBSOCKET EXCEPTION');
      Logger.e('|⚠️ Exception: $e');
      Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      _isConnecting = false;
      _stopHeartbeat();
      if (!_isManuallyDisconnected) {
        _reconnect();
      }
    }
  }

  void _handleMessage(dynamic message) {
    if (message is String) {
      try {
        final Map<String, dynamic> data = jsonDecode(message);
        final String? event = data['event'];

        if (event == AppUrls.pusherConnectionEstablished) {
          final String connectionDataStr = data['data'];
          final Map<String, dynamic> connectionData = jsonDecode(
            connectionDataStr,
          );
          _socketId = connectionData['socket_id'];
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|✅ WEBSOCKET ESTABLISHED');
          Logger.d('|🔗 Socket ID: $_socketId');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _isConnecting = false;
          _isConnected = true;
          _reconnectAttempts = 0;
          _startHeartbeat();
          _authenticateAndSubscribe();
        } else if (event == AppUrls.pusherSubscriptionSucceeded) {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|✅ WEBSOCKET SUBSCRIPTION SUCCESS');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        } else if (event == AppUrls.pusherPing) {
          _send(AppUrls.pusherPong);
        } else if (event == AppUrls.pusherPong) {
          if (_lastPingSentAt != null) {
            WebSocketState.currentPingMs.value = DateTime.now().difference(_lastPingSentAt!).inMilliseconds;
            _lastPingSentAt = null;
          }
        } else if (event != null) {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT ROUTED: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          WebSocketEventRouter.routeEvent(event, data['data']);
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

  Future<void> _authenticateAndSubscribe() async {
    if (_socketId == null || _userId == null) return;

    final Set<String> channelsToSubscribe = {
      AppUrls.privateUserChannel(_userId!),
      AppUrls.presenceRoomChannel,
      'astrologers',
      'live-sessions',
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

    // Flush any pending queued messages now that channels are authenticated
    _flushOfflineQueue();
  }

  void _flushOfflineQueue() {
    if (_offlineQueue.isEmpty || !_isConnected || _channel == null) return;
    Logger.d('|📤 Flushing ${_offlineQueue.length} queued offline WebSocket messages...');
    final List<String> pending = List.from(_offlineQueue);
    _offlineQueue.clear();
    for (final msg in pending) {
      _send(msg);
    }
  }

  void _sendRaw(String data) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(data);
    }
  }

  void _send(String data) {
    if (_channel != null && _isConnected) {
      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      Logger.d('|📤 WEBSOCKET SENT');
      Logger.d('|📦 Data: $data');
      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      _channel!.sink.add(data);
    } else {
      Logger.w('|⚠️ WebSocket disconnected. Adding message to offline queue.');
      if (_offlineQueue.length < 50) {
        _offlineQueue.add(data);
      }
    }
  }

  void _reconnect() {
    if (_isManuallyDisconnected) return;
    final bool isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
    if (!isLoggedIn) return;
    if (_isConnecting || _isConnected) return;
    if (_reconnectTimer != null && _reconnectTimer!.isActive) return;

    _reconnectAttempts++;
    final delaySeconds = min(30, max(2, pow(2, min(5, _reconnectAttempts)).toInt()));
    Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    Logger.d('|⏱️ WEBSOCKET RECONNECTING');
    Logger.d('|⚠️ Attempting to reconnect in $delaySeconds seconds (Attempt $_reconnectAttempts)...');
    Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_isConnected && !_isConnecting && !_isManuallyDisconnected) {
        connect();
      }
    });
  }

  void disconnect() {
    Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    Logger.d('|🔌 WEBSOCKET DISCONNECTING (Unsubscribing & Closing)');
    Logger.d('|⚠️ Client manually closing connection.');
    Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _isManuallyDisconnected = true;

    // Unsubscribe from all active channels before closing connection
    if (_isConnected && _channel != null) {
      for (final channelName in _subscribedChannels.toList()) {
        try {
          _sendRaw(jsonEncode({
            "event": "pusher:unsubscribe",
            "data": {
              "channel": channelName
            }
          }));
        } catch (_) {}
      }
    }

    _isConnected = false;
    _isConnecting = false;
    _socketId = null;
    _userId = null;
    currentUserId = null;
    _token = null;
    _reconnectAttempts = 0;
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _offlineQueue.clear();
    _subscribedChannels.clear();
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    disconnect();
    super.onClose();
  }

}
