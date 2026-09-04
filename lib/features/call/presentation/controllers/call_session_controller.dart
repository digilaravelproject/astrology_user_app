import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/services/websocket/websocket_service.dart';
import 'package:astro_user/core/services/local_notification_service.dart';
import 'package:astro_user/core/services/sound_vibration_service.dart';
import 'package:astro_user/core/utils/logger.dart';
import 'package:astro_user/core/utils/custom_snackbar.dart';
import 'package:astro_user/features/call/presentation/widgets/floating_call_bubble.dart';
import 'package:astro_user/features/call/presentation/pages/call_screen.dart';
import 'package:astro_user/core/services/foreground_task_service.dart';
import 'call_controller.dart';
import 'package:astro_user/routes/app_routes.dart';

class CallSessionController extends GetxController with WidgetsBindingObserver {
  final RxString status = 'idle'.obs;
  final RxInt durationSeconds = 0.obs;

  bool isMuted = false;
  bool isSpeakerOn = false;
  bool isCallScreenVisible = false;
  bool isPackageCall = false;
  bool isChatAlsoActive = false;
  int? activeChatSessionId;

  int? sessionId;
  int? providerId;
  String? providerName;
  String? providerImage;

  Timer? callTimer;
  Timer? ringingTimer;
  bool isSummaryShown = false;

  StreamSubscription? _acceptedSubscription;
  StreamSubscription? _dismissedSubscription;
  StreamSubscription? _iceSubscription;
  StreamSubscription? _endedSubscription;
  StreamSubscription? _packageTerminatedSub;

  CallController get _orchestrator => Get.find<CallController>();
  ApiClient get _apiClient => Get.find<ApiClient>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    setupWebSocketListeners();
    _packageTerminatedSub = WebSocketService.isPackageSessionTerminated.listen((isTerminated) {
      if (isTerminated && isPackageCall) {
        handlePackageTerminated();
      }
    });
    ForegroundTaskService.listenTaskData((data) {
      if (data is Map) {
        if (data['action'] == 'hangup') {
          if (sessionId != null) {
            handleCallEnded('user_hung_up');
          }
        } else if (data['action'] == 'tap') {
          if (providerId != null) {
            Get.toNamed(Routes.callScreen);
          }
        }
      }
    });
  }

  void setupWebSocketListeners() {
    _acceptedSubscription = WebSocketService.callAcceptedData.listen((data) async {
      if (data.isNotEmpty && (status.value == 'dialing' || status.value == 'ringing')) {
        final session = data['session'];
        if (session != null) {
          final incomingSessionId = int.tryParse(session['id']?.toString() ?? '');
          if (incomingSessionId == sessionId) {
            String? answer = data['answer']?.toString() ?? session['answer']?.toString();
            if (answer == null || answer.isEmpty) {
              try {
                final response = await _apiClient.get(AppUrls.currentCallSession, handleError: false, showErrorScreen: false);
                if (response.isSuccess && response.body != null) {
                  final dataMap = response.body['data'] ?? response.body;
                  final activeSession = dataMap['session'] ?? dataMap;
                  answer = activeSession['answer']?.toString() ?? activeSession['answer_sdp']?.toString();
                }
              } catch (e) {}
            }
            if (answer != null && answer.isNotEmpty) {
              _orchestrator.webrtc.handleCallAccepted(answer);
            }
          }
        }
      }
    });

    _dismissedSubscription = WebSocketService.callDismissedData.listen((data) {
      if (data.isNotEmpty) {
        final session = data['session'];
        if (session != null) {
          final incomingId = int.tryParse(session['id']?.toString() ?? '');
          if (incomingId == sessionId) {
            final reason = data['reason']?.toString() ?? 'dismissed';
            handleCallDismissed(reason);
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
            if (candidate != null && receiverId == WebSocketService.currentUserId) {
              _orchestrator.webrtcService.addRemoteCandidate(candidate);
            }
          }
        }
      }
    });

    _endedSubscription = WebSocketService.callEndedData.listen((data) {
      if (data.isNotEmpty) {
        final session = data['session'];
        if (session != null) {
          final incomingId = int.tryParse(session['id']?.toString() ?? '');
          if (incomingId == sessionId) {
            handleCallEnded(data);
          }
        }
      }
    });
  }

  void handleCallDismissed(String reason) {
    status.value = reason;
    final wasCallScreenVisible = isCallScreenVisible;
    cleanUp();
    if (wasCallScreenVisible) Get.back();
    if (reason == 'cancelled') {
      CustomSnackbar.showInfo('Call cancelled.');
    } else {
      CustomSnackbar.showError('Call dismissed: $reason');
    }
  }

  void handleCallEnded(Map<String, dynamic> data) {
    if (isSummaryShown) return;
    isSummaryShown = true;
    status.value = 'completed';
    CustomSnackbar.showInfo('Call ended.');
    
    final wasCallScreenVisible = isCallScreenVisible;
    cleanUp();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (wasCallScreenVisible) Get.back();
    });
  }

  void handlePackageTerminated() {
    status.value = 'completed';
    cleanUp();
    if (isCallScreenVisible) Get.back();
    Get.dialog(
      AlertDialog(
        title: const Text("Session Expired"),
        content: const Text("Your prepaid package session has expired. Conversation has ended."),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("OK")),
        ],
      ),
    );
  }

  void startRingingTimeout() {
    ringingTimer?.cancel();
    ringingTimer = Timer(const Duration(seconds: 60), () {
      if (status.value == 'ringing' || status.value == 'dialing' || status.value == 'waiting') {
        status.value = 'missed';
        CustomSnackbar.showError('Call unanswered.');
        cleanUp();
      }
    });
  }

  void startCallTimer() {
    callTimer?.cancel();
    callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      durationSeconds.value++;
    });
  }

  void showOngoingNotification({int? startedAtMillis}) {
    if (sessionId != null) {
      DateTime? startedAt;
      if (startedAtMillis != null) {
        startedAt = DateTime.fromMillisecondsSinceEpoch(startedAtMillis);
      }
      ForegroundTaskService.startActiveSessionNotification(
        title: 'Active Call with $providerName',
        type: 'Call',
        startedAt: startedAt,
      );
    }
  }

  void startRingtone({required bool isIncoming}) {
    if (!isIncoming) {
      SoundVibrationService().startRingtone('audio/user_app_sound.mp3', loop: true, vibrate: true);
    }
  }

  void stopRingtone() {
    SoundVibrationService().stopRingtone();
  }

  void cleanUp() {
    stopRingtone();
    callTimer?.cancel();
    ringingTimer?.cancel();
    if (sessionId != null) LocalNotificationService.cancelOngoingCallNotification(sessionId!);
    try { ForegroundTaskService.stopService(); } catch (_) {}
    FloatingCallBubble.dismiss();
    _orchestrator.webrtcService.dispose();
    status.value = 'idle';
    _orchestrator.isMuted.value = false;
    _orchestrator.isSpeakerOn.value = false;
    sessionId = null;
    providerId = null;
    providerName = null;
    providerImage = null;
    isChatAlsoActive = false;
    activeChatSessionId = null;
    if (isCallScreenVisible) isCallScreenVisible = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if ((status.value == 'ongoing' || status.value == 'ringing' || status.value == 'dialing' || status.value == 'waiting') && sessionId != null && providerName != null) {
        minimizeToBubble(Get.context!, providerName!, providerImage ?? "", shouldPop: false);
      }
    } else if (state == AppLifecycleState.resumed) {
      _orchestrator.webrtc.checkCurrentActiveCallSession();
    }
  }

  void minimizeToBubble(BuildContext context, String name, String image, {bool shouldPop = true}) {
    if (sessionId == null || (status.value != 'ongoing' && status.value != 'ringing' && status.value != 'dialing' && status.value != 'waiting')) return;
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
        FloatingCallBubble.dismiss(stopForegroundService: false);
        Get.toNamed(AppRoutes.callScreen);
      },
    );
    if (shouldPop) Get.back();
  }

  @override
  void onClose() {
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
