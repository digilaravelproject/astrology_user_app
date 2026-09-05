import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_user/core/services/websocket/websocket_service.dart';
import 'package:astro_user/core/services/sound_vibration_service.dart';
import 'package:astro_user/core/services/foreground_task_service.dart';
import 'package:astro_user/core/utils/logger.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/utils/custom_snackbar.dart';

import 'package:astro_user/routes/app_routes.dart';
import 'package:astro_user/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_user/features/chat/domain/usecases/end_chat_session_usecase.dart';
import 'package:astro_user/features/chat/domain/usecases/cancel_chat_session_usecase.dart';
import 'package:astro_user/features/auth/presentation/controllers/auth_controller.dart';
import 'package:astro_user/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_user/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_user/core/services/storage/shared_prefs.dart';
import 'package:astro_user/core/constants/app_constants.dart';
import 'package:astro_user/features/auth/data/models/user_model.dart';
import 'package:astro_user/core/services/local_notification_service.dart';
import 'package:astro_user/core/utils/session_bottom_sheet_helper.dart';
import 'package:astro_user/features/chat/domain/entities/chat_session.dart';
import 'chat_controller.dart';

class ChatSessionController extends GetxController with WidgetsBindingObserver {
  final EndChatSessionUseCase _endChatSessionUseCase;
  final CancelChatSessionUseCase _cancelChatSessionUseCase;

  ChatSessionController({
    required EndChatSessionUseCase endChatSessionUseCase,
    required CancelChatSessionUseCase cancelChatSessionUseCase,
  })  : _endChatSessionUseCase = endChatSessionUseCase,
        _cancelChatSessionUseCase = cancelChatSessionUseCase;

  final RxString status = 'connecting'.obs;
  final RxInt elapsedSeconds = 0.obs;
  final RxBool isLoading = false.obs;

  bool isPackageChat = false;
  bool isCallAlsoActive = false;

  Timer? timer;
  String? startedAt;
  StreamSubscription? _endSub;
  StreamSubscription? _statusSub;
  StreamSubscription? _dismissSub;
  StreamSubscription? _packageTerminatedSub;

  ChatController get _orchestrator => Get.find<ChatController>();

  void startRingtone() {
    SoundVibrationService().startRingtone('audio/user_app_sound.mp3', loop: true, vibrate: true);
  }

  void stopRingtone() {
    SoundVibrationService().stopRingtone();
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    ForegroundTaskService.listenTaskData((data) {
      if (data is Map) {
        if (data['action'] == 'hangup') {
          if (_orchestrator.sessionId != null) {
            endChatSession();
          }
        } else if (data['action'] == 'tap') {
          if (_orchestrator.peerId != null) {
            Get.toNamed(AppRoutes.chatScreen, arguments: {
              'astrologer_id': _orchestrator.peerId,
              'astrologer_name': _orchestrator.astrologerName,
            });
          }
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if ((status.value == 'ongoing' || status.value == 'initiated') && _orchestrator.sessionId != null && _orchestrator.astrologerName != null) {
        final ctx = Get.context;
        if (ctx != null) minimizeToBubble(ctx, _orchestrator.astrologerName!, "", shouldPop: false);
      }
    } else if (state == AppLifecycleState.resumed) {
      _checkPendingChatSession();
    }
  }

  Future<void> _checkPendingChatSession() async {
    try {
      final response = await Get.find<ApiClient>().get(AppUrls.getCurrentSession, handleError: false, showErrorScreen: false);
      if (!response.isSuccess) return;

      final body = response.body;
      final sessionData = body is Map ? (body['session'] ?? body['data']?['session'] ?? body['data']) : null;
      final String sessionStatus = sessionData != null ? (sessionData['status']?.toString() ?? '') : '';

      if (sessionData == null || (sessionStatus != 'initiated' && sessionStatus != 'ongoing')) {
        if (_orchestrator.sessionId != null && (status.value == 'ongoing' || status.value == 'initiated')) {
          handleChatEndedByPeer();
        }
      }
    } catch (_) {}
  }

  void setupSessionListeners() {
    _endSub?.cancel();
    if (WebSocketService.chatEndedSessionId.value == _orchestrator.sessionId) {
      handleChatEndedByPeer();
    }
    _endSub = WebSocketService.chatEndedSessionId.listen((endedSessionId) {
      if (endedSessionId == _orchestrator.sessionId) {
        handleChatEndedByPeer();
      }
    });

    _dismissSub?.cancel();
    if (WebSocketService.chatDismissedSessionId.value == _orchestrator.sessionId) {
      handleDismissed();
    }
    _dismissSub = WebSocketService.chatDismissedSessionId.listen((dismissedSessionId) {
      if (dismissedSessionId == _orchestrator.sessionId) {
        handleDismissed();
      }
    });

    _statusSub?.cancel();
    if (_orchestrator.sessionId != null && WebSocketService.sessionStatusUpdates.containsKey(_orchestrator.sessionId)) {
      final cachedStatus = WebSocketService.sessionStatusUpdates[_orchestrator.sessionId!];
      if (cachedStatus != null && (cachedStatus == 'ongoing' || cachedStatus == 'accepted') && (status.value != 'ongoing' && status.value != 'accepted')) {
        status.value = cachedStatus;
        stopRingtone();
        setupTimer(startedAt);
      }
    }
    _statusSub = WebSocketService.sessionStatusUpdates.listen((updates) {
      final sid = _orchestrator.sessionId;
      if (sid != null && updates.containsKey(sid)) {
        final newStatus = updates[sid];
        if (newStatus != null && status.value != newStatus) {
          status.value = newStatus;
          if (newStatus == 'ongoing' || newStatus == 'accepted') {
            stopRingtone();
            final startedAtStr = WebSocketService.sessionStartTimes[sid];
            final serverStartTime = parseSmartDate(startedAtStr);
            final effectiveStart = serverStartTime ?? DateTime.now();
            startedAt = effectiveStart.toUtc().toIso8601String();
            WebSocketService.sessionStartTimes[sid] = startedAt!;
            final diff = DateTime.now().difference(effectiveStart).inSeconds;
            elapsedSeconds.value = diff >= 0 ? diff : 0;
            setupTimer(startedAt);
            final startedAtMillis = effectiveStart.millisecondsSinceEpoch;
            ForegroundTaskService.startActiveSessionNotification(
              title: 'Active Chat with ${_orchestrator.astrologerName ?? 'Astrologer'}',
              type: 'Chat',
              startedAt: effectiveStart,
            );
          }
        }
      }
    });

    _packageTerminatedSub?.cancel();
    _packageTerminatedSub = WebSocketService.isPackageSessionTerminated.listen((isTerminated) {
      if (isTerminated && isPackageChat) {
        handlePackageTerminated();
      }
    });
  }

  void handleChatEndedByPeer() {
    status.value = 'ended';
    timer?.cancel();
    ForegroundTaskService.stopService();
    if (_orchestrator.sessionId != null) LocalNotificationService.cancelOngoingChatNotification(_orchestrator.sessionId!);
    FloatingChatBubble.dismiss();
    if (Get.isRegistered<AuthController>()) Get.find<AuthController>().checkLoginStatus();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (Get.isRegistered<ChatController>()) Get.back();
    });
  }

  void handleDismissed() {
    stopRingtone();
    status.value = 'ended';
    timer?.cancel();
    ForegroundTaskService.stopService();
    if (_orchestrator.sessionId != null) LocalNotificationService.cancelOngoingChatNotification(_orchestrator.sessionId!);
    FloatingChatBubble.dismiss();
    Get.back();
  }

  void handlePackageTerminated() {
    status.value = 'ended';
    timer?.cancel();
    ForegroundTaskService.stopService();
    if (_orchestrator.sessionId != null) LocalNotificationService.cancelOngoingChatNotification(_orchestrator.sessionId!);
    FloatingChatBubble.dismiss();
    WebSocketService.activeSessionId = null;
    Get.back();
    Get.dialog(AlertDialog(title: Text("Session Expired".tr), content: Text("Your prepaid package session has expired. Conversation has ended.".tr), actions: [TextButton(onPressed: () => Get.back(), child: Text("OK".tr))]));
  }

  void setupTimer(String? startedAtString) {
    timer?.cancel();
    final currentSt = status.value.toLowerCase();
    if (currentSt == 'ended' || currentSt == 'completed' || currentSt == 'cancelled' || currentSt == 'rejected') return;

    final sid = _orchestrator.sessionId;
    if (startedAtString != null && sid != null) {
      startedAt = startedAtString;
      WebSocketService.sessionStartTimes[sid] = startedAtString;
    }

    final startedAtStr = startedAtString ?? startedAt ?? (sid != null ? WebSocketService.sessionStartTimes[sid] : null);
    final dt = parseSmartDate(startedAtStr);

    if (dt != null) {
      final st = status.value.toLowerCase();
      if (st == 'ongoing' || st == 'accepted') {
        final diff = DateTime.now().difference(dt).inSeconds;
        if (FloatingChatBubble.isActive && FloatingChatBubble.sessionId == sid) {
          elapsedSeconds.value = FloatingChatBubble.currentElapsedSeconds;
        } else if (diff >= 0) {
          elapsedSeconds.value = diff;
        } else {
          elapsedSeconds.value = 0;
        }
      }
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        final st = status.value.toLowerCase();
        if (st == 'ended' || st == 'completed' || st == 'cancelled' || st == 'rejected') {
          t.cancel();
          return;
        }
        if (st == 'ongoing' || st == 'accepted') {
          final nowDiff = DateTime.now().difference(dt).inSeconds;
          if (FloatingChatBubble.isActive && FloatingChatBubble.sessionId == sid) {
            elapsedSeconds.value++;
            FloatingChatBubble.updateStatus(status.value);
          } else if (nowDiff >= 0) {
            elapsedSeconds.value = nowDiff;
          } else {
            elapsedSeconds.value++;
          }
        }
      });
    } else {
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        final st = status.value.toLowerCase();
        if (st == 'ended' || st == 'completed' || st == 'cancelled' || st == 'rejected') {
          t.cancel();
          return;
        }
        if (st == 'ongoing' || st == 'accepted') {
          elapsedSeconds.value++;
          if (sid != null) {
            final genStart = DateTime.now().subtract(Duration(seconds: elapsedSeconds.value)).toIso8601String();
            startedAt = genStart;
            WebSocketService.sessionStartTimes[sid] = genStart;
          }
        }
      });
    }
  }

  DateTime? parseSmartDate(dynamic input) {
    if (input == null) return null;
    if (input is DateTime) return input.toLocal();
    final dateStr = input.toString().trim();
    if (dateStr.isEmpty) return null;
    String isoUtc = dateStr.replaceAll(' ', 'T');
    if (!isoUtc.endsWith('Z') && !isoUtc.contains('+') && !isoUtc.contains('-')) isoUtc += 'Z';
    final utcDate = DateTime.tryParse(isoUtc)?.toLocal();
    if (utcDate != null && !utcDate.isAfter(DateTime.now())) return utcDate;
    DateTime? parsed = DateTime.tryParse(dateStr.replaceAll(' ', 'T')) ?? DateTime.tryParse(dateStr);
    return parsed?.toLocal();
  }

  Future<void> terminateChannelOnly() async {
    // Unified endpoint: /chat/{id}/end handles session_type automatically
    if (_orchestrator.sessionId == null) return;
    try {
      isLoading.value = true;
      status.value = 'ended';
      timer?.cancel();
      ForegroundTaskService.stopService();
      LocalNotificationService.cancelOngoingChatNotification(_orchestrator.sessionId!);
      FloatingChatBubble.dismiss();
      WebSocketService.activeSessionId = null;
      Get.back();
      // Call unified end endpoint — backend detects session_type (normal/prepaid) automatically
      await Get.find<ApiClient>().post(
        AppUrls.endChatSession(_orchestrator.sessionId!),
        handleError: false,
        showErrorScreen: false,
      );
    } catch (e) {
      Logger.e('terminateChannelOnly error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> terminateEntireSession() async {
    // Unified endpoint: /chat/{id}/end handles both normal & prepaid session_type
    await endChatSession();
  }

  Future<void> cancelChatSession() async {
    if (_orchestrator.sessionId == null) {
      Get.back();
      return;
    }
    final targetId = _orchestrator.sessionId!;
    stopRingtone();
    status.value = 'ended';
    timer?.cancel();
    ForegroundTaskService.stopService();
    LocalNotificationService.cancelOngoingChatNotification(targetId);
    FloatingChatBubble.dismiss();
    if (Get.isRegistered<ChatController>()) Get.back();
    try {
      await _cancelChatSessionUseCase.execute(targetId);
    } catch (_) {} finally {
      LocalNotificationService.cancelOngoingChatNotification(targetId);
      FloatingChatBubble.dismiss();
    }
  }

  Future<void> endChatSession({bool skipSummary = false}) async {
    if (_orchestrator.sessionId == null) return;
    isLoading.value = true;
    try {
      // Unified endpoint: POST /chat/{sessionId}/end
      // Backend auto-detects session_type (normal/prepaid) and settles billing accordingly
      final session = await _endChatSessionUseCase.execute(_orchestrator.sessionId!);
      status.value = 'ended';
      timer?.cancel();
      ForegroundTaskService.stopService();
      LocalNotificationService.cancelOngoingChatNotification(_orchestrator.sessionId!);
      FloatingChatBubble.dismiss();
      if (session != null) WebSocketService.activeSessionId = null;
    } catch (e) {
      CustomSnackbar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void minimizeToBubble(BuildContext context, String name, String image, {bool shouldPop = true}) {
    final sid = _orchestrator.sessionId;
    if (sid == null || (status.value != 'ongoing' && status.value != 'initiated')) return;
    WebSocketService.activeSessionId = null;
    final startStr = startedAt ?? WebSocketService.sessionStartTimes[sid] ?? DateTime.now().subtract(Duration(seconds: elapsedSeconds.value)).toIso8601String();
    WebSocketService.sessionStartTimes[sid] = startStr;
    FloatingChatBubble.show(
      context: context,
      sessionId: sid,
      name: name,
      imageUrl: image,
      startedAt: startStr,
      status: status.value,
      onTap: () {
        final currentStatus = FloatingChatBubble.chatStatus.value;
        FloatingChatBubble.dismiss(stopForegroundService: false);
        Get.toNamed(AppRoutes.chatScreen, arguments: {
          'astrologerName': name,
          'astrologerImage': image,
          'sessionId': sid,
          'initialStatus': currentStatus,
          'startedAtString': startStr,
          'isPackageChat': false,
        });
      },
    );
    if (shouldPop) Navigator.of(context).pop();
  }

  @override
  void onClose() {
    stopRingtone();
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    _endSub?.cancel();
    _statusSub?.cancel();
    _dismissSub?.cancel();
    _packageTerminatedSub?.cancel();
    if (status.value == 'ended' || status.value == 'completed' || status.value == 'cancelled' || status.value == 'rejected') {
      if (_orchestrator.sessionId != null) {
        LocalNotificationService.cancelOngoingChatNotification(_orchestrator.sessionId!);
      } else {
        LocalNotificationService.cancelOngoingChatNotification(null);
      }
      FloatingChatBubble.dismiss(stopForegroundService: true);
      if (WebSocketService.activeSessionId == _orchestrator.sessionId) WebSocketService.activeSessionId = null;
    }
    super.onClose();
  }
}
