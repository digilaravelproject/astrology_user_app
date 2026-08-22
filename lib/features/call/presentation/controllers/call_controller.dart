import 'dart:async';
import 'package:get/get.dart';
import 'package:astro_user/core/constants/app_constants.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/services/network/websocket_service.dart';
import 'package:astro_user/core/services/webrtc/webrtc_service.dart';
import 'package:astro_user/core/services/local_notification_service.dart';
import 'package:astro_user/core/services/sound_vibration_service.dart';
import 'package:astro_user/core/utils/logger.dart';
import 'package:astro_user/core/utils/custom_snackbar.dart';
import 'package:astro_user/features/call/presentation/widgets/call_summary_dialog.dart';
import 'package:astro_user/core/services/foreground_task_service.dart';

import 'package:flutter/material.dart';
import 'package:astro_user/features/call/presentation/widgets/floating_call_bubble.dart';
import 'package:astro_user/features/call/presentation/pages/call_screen.dart';
import 'package:astro_user/core/utils/session_bottom_sheet_helper.dart';

class CallController extends GetxController with WidgetsBindingObserver {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final WebRTCService webrtcService = WebRTCService();

  final RxString status = 'idle'.obs; // idle, dialing, waiting, ongoing, completed, rejected, cancelled, missed
  final RxInt durationSeconds = 0.obs;
  final RxBool isMuted = false.obs;
  final RxBool isSpeakerOn = false.obs;
  bool isCallScreenVisible = false;
  bool isPackageCall = false;

  int? sessionId;
  int? providerId;
  String? providerName;
  String? providerImage;

  Timer? _callTimer;
  Timer? _ringingTimer;
  bool _isSummaryShown = false;
  StreamSubscription? _acceptedSubscription;
  StreamSubscription? _dismissedSubscription;
  StreamSubscription? _iceSubscription;
  StreamSubscription? _endedSubscription;
  StreamSubscription? _packageTerminatedSub;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _setupWebSocketListeners();
    _packageTerminatedSub = WebSocketService.isPackageSessionTerminated.listen((isTerminated) {
      if (isTerminated && isPackageCall) {
        _handlePackageTerminated();
      }
    });
  }

  void _setupWebSocketListeners() {
    _acceptedSubscription = WebSocketService.callAcceptedData.listen((data) async {
      Logger.d('CallController: WebSocket callAcceptedData received: $data');
      Logger.d('CallController: Current status: ${status.value}, sessionId: $sessionId');
      if (data.isNotEmpty && (status.value == 'dialing' || status.value == 'ringing')) {
        final session = data['session'];
        if (session != null) {
          final incomingSessionId = int.tryParse(session['id']?.toString() ?? '');
          Logger.d('CallController: Matching session: incomingSessionId = $incomingSessionId, expected = $sessionId');
          if (incomingSessionId == sessionId) {
            String? answer = data['answer']?.toString() ?? session['answer']?.toString();
            Logger.d('CallController: Found answer in WS (checking root and session): ${answer != null ? "length: ${answer.length}" : "NULL"}');
            
            if (answer == null || answer.isEmpty) {
              Logger.d('CallController: Answer is null/empty in WS. Fetching from currentCallSession API...');
              try {
                final response = await _apiClient.get(AppUrls.currentCallSession, handleError: false, showErrorScreen: false);
                Logger.d('CallController: currentCallSession API response body: ${response.body}');
                if (response.isSuccess && response.body != null) {
                  final dataMap = response.body['data'] ?? response.body;
                  final activeSession = dataMap['session'] ?? dataMap;
                  answer = activeSession['answer']?.toString() ?? activeSession['answer_sdp']?.toString();
                  Logger.d('CallController: Answer from API: ${answer != null ? "length: ${answer.length}" : "NULL"}');
                }
              } catch (e) {
                Logger.e('CallController: Error fetching current call session -> $e');
              }
            }

            if (answer != null && answer.isNotEmpty) {
              _handleCallAccepted(answer);
            } else {
              Logger.e('CallController: Answer SDP is still NULL. Cannot establish WebRTC connection.');
            }
          }
        }
      }
    });

    _dismissedSubscription = WebSocketService.callDismissedData.listen((data) {
      Logger.d('CallController: WebSocket callDismissedData received: $data');
      if (data.isNotEmpty) {
        final session = data['session'];
        if (session != null) {
          final incomingId = int.tryParse(session['id']?.toString() ?? '');
          Logger.d('CallController: callDismissed match check: incoming=$incomingId, expected=$sessionId');
          if (incomingId == sessionId) {
            final reason = data['reason']?.toString() ?? 'dismissed';
            _handleCallDismissed(reason);
          }
        }
      }
    });

    _iceSubscription = WebSocketService.iceCandidateData.listen((data) {
      if (data.isNotEmpty) {
        final session = data['session'];
        if (session != null) {
          final incomingId = int.tryParse(session['id']?.toString() ?? '');
          if (incomingId == sessionId) {
            final candidate = data['candidate']?.toString();
            final receiverId = data['receiverId'];
            // Only add candidate if it is meant for us (receiverId matches current user ID)
            if (candidate != null && receiverId == WebSocketService.currentUserId) {
              webrtcService.addRemoteCandidate(candidate);
            }
          }
        }
      }
    });

    _endedSubscription = WebSocketService.callEndedData.listen((data) {
      Logger.d('CallController: WebSocket callEndedData received: $data');
      if (data.isNotEmpty) {
        final session = data['session'];
        if (session != null) {
          final incomingId = int.tryParse(session['id']?.toString() ?? '');
          if (incomingId == sessionId) {
            _handleCallEnded(data);
          }
        }
      }
    });
  }

  Future<void> initiateCall({
    required int providerId,
    required String providerName,
    required String providerImage,
    bool isPackageSession = false,
  }) async {
    try {
      _isSummaryShown = false;
      this.providerId = providerId;
      this.providerName = providerName;
      this.providerImage = providerImage;
      isPackageCall = isPackageSession;

      status.value = 'dialing';
      Logger.d('CallController: Dialing astrologer $providerName (ID: $providerId)...');

      // 1. Create SDP Offer
      // We pass a temporary sessionId (0) first since we don't have the real ID yet
      final offerDescription = await webrtcService.createOffer(0);

      // 2. Post to Initiate API
      final response = await _apiClient.post(
        isPackageSession ? AppUrls.packageSessionStart : AppUrls.initiateCall,
        data: isPackageSession
            ? {
                'astrologer_id': providerId,
                'mode': 'call',
                'offer': offerDescription.sdp,
              }
            : {
                'provider_id': providerId,
                'offer': offerDescription.sdp,
              },
        handleError: true,
        showErrorScreen: false,
      );

      if (response.isSuccess) {
        final bodyMap = response.body;
        // Since response.body already points to the 'data' map from ResponseModel.fromJson (json['data'] ?? json)
        final sessionData = bodyMap is Map 
            ? (bodyMap['session'] ?? bodyMap['call_session'] ?? bodyMap['data']?['session'] ?? bodyMap['data']?['call_session']) 
            : null;
        if (isPackageSession) {
          final subSessionData = bodyMap is Map ? (bodyMap['sub_session'] ?? bodyMap['data']?['sub_session']) : null;
          if (subSessionData != null) {
            SessionBottomSheetHelper.activeSubSessionId = int.tryParse(subSessionData['id']?.toString() ?? '');
          }
        }
        if (sessionData != null) {
          sessionId = int.tryParse(sessionData['id']?.toString() ?? '') ?? 0;
          webrtcService.activeSessionId = sessionId;
          final sessionStatus = sessionData['status']?.toString() ?? 'initiated';

          if (sessionStatus == 'waiting') {
            status.value = 'waiting';
            CustomSnackbar.showInfo('Astrologer busy. You are in queue.');
          } else {
            status.value = 'ringing';
            _startRingtone(isIncoming: false);
          }

          _startRingingTimeout();
        }
      } else {
        status.value = 'idle';
        CustomSnackbar.showError(response.body?['message']?.toString() ?? 'Failed to initiate call.');
        cleanUp();
      }
    } catch (e) {
      status.value = 'idle';
      Logger.e('CallController: Exception initiating call -> $e');
      cleanUp();
    }
  }

  Future<void> cancelCall() async {
    if (sessionId == null) {
      cleanUp();
      return;
    }
    try {
      final response = await _apiClient.post(
        AppUrls.cancelCall(sessionId!),
        handleError: true,
        showErrorScreen: false,
      );
      if (response.isSuccess) {
        status.value = 'cancelled';
        CustomSnackbar.showSuccess('Call cancelled.');
      }
    } catch (e) {
      Logger.e('CallController: Error cancelling call -> $e');
    } finally {
      cleanUp();
    }
  }

  Future<void> endCall() async {
    if (sessionId == null) return;
    try {
      final response = isPackageCall && SessionBottomSheetHelper.activeSubSessionId != null
          ? await _apiClient.post(
              AppUrls.packageSessionEnd,
              data: {'sub_session_id': SessionBottomSheetHelper.activeSubSessionId},
            )
          : await _apiClient.post(
              AppUrls.endCallSession(sessionId!),
              handleError: true,
              showErrorScreen: false,
            );
      if (response.isSuccess) {
        if (_isSummaryShown) return;
        _isSummaryShown = true;
        
        status.value = 'completed';
        CustomSnackbar.showSuccess('Call ended successfully.');
        
        final bodyMap = response.body;
        final sessionData = bodyMap is Map 
            ? (bodyMap['session'] ?? bodyMap['data']?['session'] ?? bodyMap['sub_session'] ?? bodyMap['data']?['sub_session'] ?? bodyMap['data']) 
            : null;
        int duration = 0;
        double cost = 0.0;
        if (sessionData != null && sessionData is Map) {
          duration = int.tryParse((sessionData['duration_seconds'] ?? sessionData['duration_used'])?.toString() ?? '') ?? 0;
          cost = double.tryParse(sessionData['total_cost']?.toString() ?? '') ?? 0.0;
        }
        
        final sId = sessionId ?? 0;
        cleanUp();
        if (isCallScreenVisible) {
          Get.back();
        }
      }
    } catch (e) {
      Logger.e('CallController: Error ending call -> $e');
      cleanUp();
    }
  }

  void toggleMute() {
    isMuted.value = !isMuted.value;
    webrtcService.toggleMute(isMuted.value);
  }

  void toggleSpeaker() {
    isSpeakerOn.value = !isSpeakerOn.value;
    webrtcService.toggleSpeaker(isSpeakerOn.value);
  }

  Future<void> _handleCallAccepted(String answerSdp) async {
    _stopRingtone();
    _ringingTimer?.cancel();
    status.value = 'ongoing';
    durationSeconds.value = 0;

    final acceptedMillis = DateTime.now().millisecondsSinceEpoch;
    LocalNotificationService.cancelIncomingCallNotification(sessionId!);
    _startCallTimer();
    _showOngoingNotification(startedAtMillis: acceptedMillis);

    try {
      await webrtcService.setRemoteAnswer(answerSdp);
    } catch (e) {
      Logger.e('CallController: Error setting remote answer -> $e');
    }
  }

  void _handleCallDismissed(String reason) {
    status.value = reason; // rejected, cancelled, timeout
    final wasCallScreenVisible = isCallScreenVisible;
    cleanUp();
    if (wasCallScreenVisible) {
      Get.back(); // Close CallScreen safely
    }
    if (reason == 'cancelled') {
      CustomSnackbar.showInfo('Call cancelled.');
    } else {
      CustomSnackbar.showError('Call dismissed: $reason');
    }
  }

  void _handleCallEnded(Map<String, dynamic> data) {
    if (_isSummaryShown) return;
    _isSummaryShown = true;
    
    status.value = 'completed';
    CustomSnackbar.showInfo('Call ended.');
    
    final session = data['session'];
    int sId = sessionId ?? 0;
    int duration = 0;
    double cost = 0.0;
    
    if (session != null) {
      sId = int.tryParse(session['id']?.toString() ?? '') ?? sId;
      duration = int.tryParse(session['duration_seconds']?.toString() ?? '') ?? 0;
      cost = double.tryParse(session['total_cost']?.toString() ?? '') ?? 0.0;
    }
    
    final wasCallScreenVisible = isCallScreenVisible;
    cleanUp();

    // Close CallScreen safely on main thread
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (wasCallScreenVisible) {
        Get.back();
      }
    });
  }

  void _startRingingTimeout() {
    _ringingTimer?.cancel();
    _ringingTimer = Timer(const Duration(seconds: 60), () {
      if (status.value == 'ringing' || status.value == 'dialing' || status.value == 'waiting') {
        status.value = 'missed';
        CustomSnackbar.showError('Call unanswered.');
        cleanUp();
      }
    });
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      durationSeconds.value++;
    });
  }

  void _showOngoingNotification({int? startedAtMillis}) {
    if (sessionId != null) {
      LocalNotificationService.showOngoingCallNotification(
        sessionId: sessionId!,
        title: 'Active Call in Progress',
        body: 'Talking with $providerName',
        startedAtMillis: startedAtMillis,
      );
    }
  }

  void _startRingtone({required bool isIncoming}) {
    // outgoing_ring.mp3 = user hears this while waiting for astrologer to accept
    // incoming_ring.mp3 = would be for astrologer (not used on user side)
    final sound = isIncoming ? 'audio/incoming_ring.mp3' : 'audio/outgoing_ring.mp3';
    SoundVibrationService().startRingtone(sound, loop: true, vibrate: false);
    Logger.d('[CallController] Ringtone started → $sound');
  }

  void _stopRingtone() {
    SoundVibrationService().stopRingtone();
    Logger.d('[CallController] Ringtone stopped');
  }

  void cleanUp() {
    if (status.value == 'idle' && sessionId == null) return;
    _stopRingtone();
    _callTimer?.cancel();
    _ringingTimer?.cancel();
    if (sessionId != null) {
      LocalNotificationService.cancelOngoingCallNotification(sessionId!);
    }
    try {
      ForegroundTaskService.stopService();
    } catch (_) {}
    FloatingCallBubble.dismiss();
    webrtcService.dispose();
    status.value = 'idle';
    isMuted.value = false;
    isSpeakerOn.value = false;
    sessionId = null;
    providerId = null;
    providerName = null;
    providerImage = null;

    if (isCallScreenVisible) {
      isCallScreenVisible = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if ((status.value == 'ongoing' || status.value == 'ringing' || status.value == 'dialing' || status.value == 'waiting') && sessionId != null && providerName != null) {
        minimizeToBubble(Get.context!, providerName!, providerImage ?? "", shouldPop: false);
      }
    } else if (state == AppLifecycleState.resumed) {
      checkCurrentActiveCallSession();
    }
  }

  void minimizeToBubble(BuildContext context, String name, String image, {bool shouldPop = true}) {
    debugPrint("==== [CALL_DEBUG] CallController.minimizeToBubble called! sessionId=$sessionId, status=${status.value}, shouldPop=$shouldPop ====");
    if (sessionId == null || (status.value != 'ongoing' && status.value != 'ringing' && status.value != 'dialing' && status.value != 'waiting')) {
      debugPrint("==== [CALL_DEBUG] minimizeToBubble SKIPPED because sessionId is null or status invalid ====");
      return;
    }
    final startStr = WebSocketService.sessionStartTimes[sessionId!] ?? DateTime.now().subtract(Duration(seconds: durationSeconds.value)).toIso8601String();
    WebSocketService.sessionStartTimes[sessionId!] = startStr;

    FloatingCallBubble.show(
      context: context,
      sessionId: sessionId!,
      name: name,
      imageUrl: image,
      startedAt: status.value == 'ongoing' ? startStr : null,
      status: status.value,
      onTap: () {
        debugPrint("==== [CALL_DEBUG] FloatingCallBubble tapped! Returning to CallScreen ====");
        FloatingCallBubble.dismiss(stopForegroundService: false);
        Get.to(() => const CallScreen());
      },
    );
    if (shouldPop) {
      Get.back();
    }
  }

  Future<void> checkCurrentActiveCallSession() async {
    try {
      final response = await _apiClient.get(AppUrls.currentCallSession, handleError: false, showErrorScreen: false);
      if (response.isSuccess && response.body != null) {
        final bodyMap = response.body;
        final session = bodyMap is Map 
            ? (bodyMap['session'] ?? bodyMap['data']?['session'] ?? bodyMap['data'] ?? bodyMap)
            : null;
        if (session != null) {
          final sessionStatus = session['status']?.toString();
          if (sessionStatus == 'ongoing' || sessionStatus == 'ringing' || sessionStatus == 'dialing' || sessionStatus == 'waiting') {
            _isSummaryShown = false;
            sessionId = int.tryParse(session['id']?.toString() ?? '');
            webrtcService.activeSessionId = sessionId;
            status.value = sessionStatus!;
            
            providerId = int.tryParse(session['provider_id']?.toString() ?? '');
            final provider = session['provider'];
            providerName = provider?['name']?.toString() ?? 'Astrologer';
            providerImage = provider?['image']?.toString() ?? provider?['profile_image']?.toString() ?? '';
            
            if (sessionStatus == 'ongoing') {
              final startedAtStr = session['started_at']?.toString();
              if (startedAtStr != null) {
                final startedAt = DateTime.tryParse(startedAtStr)?.toLocal();
                if (startedAt != null) {
                  durationSeconds.value = DateTime.now().difference(startedAt).inSeconds;
                  _startCallTimer();
                }
              }
              
              final answer = session['answer']?.toString() ?? session['answer_sdp']?.toString();
              if (answer != null && answer.isNotEmpty) {
                await webrtcService.createOffer(sessionId!);
                await webrtcService.setRemoteAnswer(answer);
              }
            } else if (sessionStatus == 'ringing' || sessionStatus == 'dialing') {
              _startRingtone(isIncoming: false);
              _startRingingTimeout();
            }
            
            // Show Notification
            final minutes = (durationSeconds.value ~/ 60).toString().padLeft(2, '0');
            final seconds = (durationSeconds.value % 60).toString().padLeft(2, '0');
            LocalNotificationService.showOngoingCallNotification(
              sessionId: sessionId!,
              title: '$providerName • Call',
              body: 'Tap to return to call session',
              startedAtMillis: () {
                if (sessionStatus == 'ongoing' && session['started_at'] != null) {
                  String isoUtc = session['started_at'].toString().trim().replaceAll(' ', 'T');
                  if (!isoUtc.endsWith('Z') && !isoUtc.contains('+') && !isoUtc.contains('-')) {
                    isoUtc += 'Z';
                  }
                  return DateTime.tryParse(isoUtc)?.toLocal().millisecondsSinceEpoch;
                }
                return null;
              }(),
            );

            // Show Floating Bubble
            if (!isCallScreenVisible) {
              FloatingCallBubble.show(
                context: Get.context!,
                sessionId: sessionId!,
                name: providerName!,
                imageUrl: providerImage ?? "",
                startedAt: session['started_at']?.toString(),
                status: status.value,
                onTap: () {
                  final currentStatus = FloatingCallBubble.callStatus.value;
                  FloatingCallBubble.dismiss();
                  Get.to(() => const CallScreen());
                },
              );
            }
          } else {
            cleanUp();
          }
        } else {
          cleanUp();
        }
      } else {
        cleanUp();
      }
    } catch (e) {
      Logger.e('CallController: Error checking current active call session -> $e');
    }
  }

  void _handlePackageTerminated() {
    status.value = 'completed';
    cleanUp();
    if (isCallScreenVisible) {
      Get.back();
    }
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
    debugPrint("==== [CALL_DEBUG] CallController.onClose invoked! sessionId=$sessionId, status=${status.value} ====");
    WidgetsBinding.instance.removeObserver(this);
    _acceptedSubscription?.cancel();
    _dismissedSubscription?.cancel();
    _iceSubscription?.cancel();
    _endedSubscription?.cancel();
    _packageTerminatedSub?.cancel();
    cleanUp();
    super.onClose();
  }
}
