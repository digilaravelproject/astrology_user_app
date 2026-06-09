import 'dart:async';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:astro_user/core/constants/app_constants.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/services/network/websocket_service.dart';
import 'package:astro_user/core/services/webrtc/webrtc_service.dart';
import 'package:astro_user/core/services/local_notification_service.dart';
import 'package:astro_user/core/utils/logger.dart';
import 'package:astro_user/core/utils/custom_snackbar.dart';

class CallController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final WebRTCService webrtcService = WebRTCService();

  final RxString status = 'idle'.obs; // idle, dialing, waiting, ongoing, completed, rejected, cancelled, missed
  final RxInt durationSeconds = 0.obs;
  final RxBool isMuted = false.obs;
  final RxBool isSpeakerOn = false.obs;

  int? sessionId;
  int? providerId;
  String? providerName;
  String? providerImage;

  AudioPlayer? _audioPlayer;
  Timer? _callTimer;
  Timer? _ringingTimer;
  StreamSubscription? _acceptedSubscription;
  StreamSubscription? _dismissedSubscription;
  StreamSubscription? _iceSubscription;
  StreamSubscription? _endedSubscription;

  @override
  void onInit() {
    super.onInit();
    _setupWebSocketListeners();
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
        if (session != null && session['id'] == sessionId) {
          final reason = data['reason']?.toString() ?? 'dismissed';
          _handleCallDismissed(reason);
        }
      }
    });

    _iceSubscription = WebSocketService.iceCandidateData.listen((data) {
      if (data.isNotEmpty) {
        final session = data['session'];
        if (session != null && session['id'] == sessionId) {
          final candidate = data['candidate']?.toString();
          final receiverId = data['receiverId'];
          // Only add candidate if it is meant for us (receiverId matches current user ID)
          if (candidate != null && receiverId == WebSocketService.currentUserId) {
            webrtcService.addRemoteCandidate(candidate);
          }
        }
      }
    });

    _endedSubscription = WebSocketService.callEndedData.listen((data) {
      Logger.d('CallController: WebSocket callEndedData received: $data');
      if (data.isNotEmpty) {
        final session = data['session'];
        if (session != null && session['id'] == sessionId) {
          _handleCallEnded(data);
        }
      }
    });
  }

  Future<void> initiateCall({
    required int providerId,
    required String providerName,
    required String providerImage,
  }) async {
    try {
      this.providerId = providerId;
      this.providerName = providerName;
      this.providerImage = providerImage;

      status.value = 'dialing';
      Logger.d('CallController: Dialing astrologer $providerName (ID: $providerId)...');

      // 1. Create SDP Offer
      // We pass a temporary sessionId (0) first since we don't have the real ID yet
      final offerDescription = await webrtcService.createOffer(0);

      // 2. Post to Initiate API
      final response = await _apiClient.post(
        AppUrls.initiateCall,
        data: {
          'provider_id': providerId,
          'offer': offerDescription.sdp,
        },
        handleError: true,
        showErrorScreen: false,
      );

      if (response.isSuccess) {
        final bodyMap = response.body;
        // Since response.body already points to the 'data' map from ResponseModel.fromJson (json['data'] ?? json)
        final sessionData = bodyMap is Map ? (bodyMap['session'] ?? bodyMap['data']?['session']) : null;
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
    if (sessionId == null) return;
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
      final response = await _apiClient.post(
        AppUrls.endCallSession(sessionId!),
        handleError: true,
        showErrorScreen: false,
      );
      if (response.isSuccess) {
        status.value = 'completed';
        CustomSnackbar.showSuccess('Call ended successfully.');
      }
    } catch (e) {
      Logger.e('CallController: Error ending call -> $e');
    } finally {
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

    await webrtcService.setRemoteAnswer(answerSdp);
    _startCallTimer();
    _showOngoingNotification();
  }

  void _handleCallDismissed(String reason) {
    status.value = reason; // rejected, cancelled, timeout
    if (reason == 'cancelled') {
      CustomSnackbar.showInfo('Call cancelled.');
    } else {
      CustomSnackbar.showError('Call dismissed: $reason');
    }
    cleanUp();
  }

  void _handleCallEnded(Map<String, dynamic> data) {
    status.value = 'completed';
    CustomSnackbar.showInfo('Call ended by astrologer.');
    cleanUp();
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
      _showOngoingNotification();
    });
  }

  void _showOngoingNotification() {
    if (sessionId != null) {
      final minutes = (durationSeconds.value ~/ 60).toString().padLeft(2, '0');
      final seconds = (durationSeconds.value % 60).toString().padLeft(2, '0');
      LocalNotificationService.showOngoingCallNotification(
        sessionId: sessionId!,
        title: 'Active Call in Progress',
        body: 'Talking with $providerName - $minutes:$seconds',
      );
    }
  }

  Future<void> _startRingtone({required bool isIncoming}) async {
    try {
      _audioPlayer = AudioPlayer();
      final path = isIncoming ? AppConstants.incomingRingPath : AppConstants.outgoingRingPath;
      await _audioPlayer?.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer?.play(AssetSource(path));

      if (isIncoming && (await Vibration.hasVibrator() ?? false)) {
        Vibration.vibrate(pattern: [500, 1000, 500, 1000], repeat: 0);
      }
    } catch (e) {
      Logger.e('CallController: Error playing ringtone -> $e');
    }
  }

  void _stopRingtone() {
    _audioPlayer?.stop();
    _audioPlayer?.dispose();
    _audioPlayer = null;
    Vibration.cancel();
  }

  void cleanUp() {
    _stopRingtone();
    _callTimer?.cancel();
    _ringingTimer?.cancel();
    if (sessionId != null) {
      LocalNotificationService.cancelOngoingCallNotification(sessionId!);
    }
    webrtcService.dispose();
    status.value = 'idle';
  }

  @override
  void onClose() {
    _acceptedSubscription?.cancel();
    _dismissedSubscription?.cancel();
    _iceSubscription?.cancel();
    _endedSubscription?.cancel();
    cleanUp();
    super.onClose();
  }
}
