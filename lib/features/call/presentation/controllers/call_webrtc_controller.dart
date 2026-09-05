import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/services/websocket/websocket_service.dart';
import 'package:astro_user/core/services/local_notification_service.dart';
import 'package:astro_user/core/utils/logger.dart';
import 'package:astro_user/core/utils/custom_snackbar.dart';
import 'package:astro_user/features/call/presentation/widgets/floating_call_bubble.dart';
import 'package:astro_user/features/call/presentation/pages/call_screen.dart';
import 'package:astro_user/core/utils/session_bottom_sheet_helper.dart';
import 'package:astro_user/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_user/features/chat/presentation/bindings/chat_binding.dart';
import 'call_controller.dart';
import 'package:astro_user/routes/app_routes.dart';

class CallWebRTCController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  CallController get _orchestrator => Get.find<CallController>();

  Future<void> initiateCall({
    required int providerId,
    required String providerName,
    required String providerImage,
    bool isPackageSession = false,
  }) async {
    try {
      _orchestrator.session.isSummaryShown = false;
      _orchestrator.session.providerId = providerId;
      _orchestrator.session.providerName = providerName;
      _orchestrator.session.providerImage = providerImage;
      _orchestrator.session.isPackageCall = isPackageSession;

      _orchestrator.status.value = 'dialing';
      final offerDescription = await _orchestrator.webrtcService.createOffer(0);

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
        final sessionData = bodyMap is Map 
            ? (bodyMap['session'] ?? bodyMap['call_session'] ?? bodyMap['data']?['session'] ?? bodyMap['data']?['call_session']) 
            : null;
        if (isPackageSession) {
          final subSessionData = bodyMap is Map ? (bodyMap['sub_session'] ?? bodyMap['data']?['sub_session']) : null;
          if (subSessionData != null) {
            SessionBottomSheetHelper.activeSubSessionId = int.tryParse(subSessionData['id']?.toString() ?? '');
          }
          final remainingSecs = bodyMap is Map
              ? (bodyMap['remaining_duration'] ?? bodyMap['data']?['remaining_duration'])
              : null;
          if (remainingSecs != null) {
            WebSocketService.packageRemainingSeconds.value = int.tryParse(remainingSecs.toString()) ?? 0;
          }
        }
        if (sessionData != null) {
          _orchestrator.session.sessionId = int.tryParse(sessionData['id']?.toString() ?? '') ?? 0;
          _orchestrator.webrtcService.activeSessionId = _orchestrator.sessionId;
          final sessionStatus = sessionData['status']?.toString() ?? 'initiated';

          if (sessionStatus == 'waiting') {
            _orchestrator.status.value = 'waiting';
            CustomSnackbar.showInfo('Astrologer busy. You are in queue.');
          } else {
            _orchestrator.status.value = 'ringing';
            _orchestrator.session.startRingtone(isIncoming: false);
          }
          _orchestrator.session.startRingingTimeout();
        }
      } else {
        _orchestrator.status.value = 'idle';
        CustomSnackbar.showError(response.body?['message']?.toString() ?? 'Failed to initiate call.');
        _orchestrator.session.cleanUp();
      }
    } catch (e) {
      _orchestrator.status.value = 'idle';
      _orchestrator.session.cleanUp();
    }
  }

  Future<void> cancelCall() async {
    if (_orchestrator.sessionId == null) {
      _orchestrator.session.cleanUp();
      return;
    }
    try {
      final response = await _apiClient.post(
        AppUrls.cancelCall(_orchestrator.sessionId!),
        handleError: true,
        showErrorScreen: false,
      );
      if (response.isSuccess) {
        _orchestrator.status.value = 'cancelled';
        CustomSnackbar.showSuccess('Call cancelled.');
      }
    } catch (e) {} finally {
      _orchestrator.session.cleanUp();
    }
  }

  Future<void> endCall() async {
    if (_orchestrator.sessionId == null) return;
    try {
      final response = _orchestrator.session.isPackageCall && SessionBottomSheetHelper.activeSubSessionId != null
          ? await _apiClient.post(
              AppUrls.packageSessionEnd,
              data: {'sub_session_id': SessionBottomSheetHelper.activeSubSessionId},
            )
          : await _apiClient.post(
              AppUrls.endCallSession(_orchestrator.sessionId!),
              handleError: true,
              showErrorScreen: false,
            );
      if (response.isSuccess) {
        if (_orchestrator.session.isSummaryShown) return;
        _orchestrator.session.isSummaryShown = true;
        
        _orchestrator.status.value = 'completed';
        CustomSnackbar.showSuccess('Call ended successfully.');
        
        final wasCallScreenVisible = _orchestrator.isCallScreenVisible;
        _orchestrator.session.cleanUp();
        if (wasCallScreenVisible || Get.currentRoute == '/CallScreen' || Get.currentRoute == '/call-screen' || Get.currentRoute == '/call') {
          if (Get.isDialogOpen ?? false) Get.back();
          Get.back();
        }
      }
    } catch (e) {
      _orchestrator.session.cleanUp();
    }
  }

  Future<void> terminateChannelOnly() async {
    final subId = PackageSessionService.activeSubSessionId ?? SessionBottomSheetHelper.activeSubSessionId;
    if (subId == null) return;
    try {
      await PackageSessionService.terminateChannel(
        subSessionId: subId,
        channelType: 'call',
        action: 'channel_only',
      );

      final chatSessId = _orchestrator.session.activeChatSessionId ?? 0;
      final pName = _orchestrator.session.providerName ?? 'Astrologer';
      final pImage = _orchestrator.session.providerImage ?? '';

      final wasVisible = _orchestrator.isCallScreenVisible;
      _orchestrator.session.cleanUp();
      if (wasVisible || Get.currentRoute == '/CallScreen' || Get.currentRoute == '/call-screen' || Get.currentRoute == '/call') {
        if (Get.isDialogOpen ?? false) Get.back();
        Get.back();
      }

      if (chatSessId > 0) {
        Get.to(
          () => ChatScreen(
            astrologerName: pName,
            astrologerImage: pImage,
            sessionId: chatSessId,
            initialStatus: 'ongoing',
            isPackageChat: true,
          ),
          binding: ChatBinding(),
        );
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to end call. Please try again.');
    }
  }

  Future<void> terminateEntireSession() async {
    final subId = PackageSessionService.activeSubSessionId ?? SessionBottomSheetHelper.activeSubSessionId;
    if (subId == null) {
      await endCall();
      return;
    }
    try {
      await PackageSessionService.terminateChannel(
        subSessionId: subId,
        channelType: 'call',
        action: 'complete_session',
      );
      _orchestrator.status.value = 'completed';
      final wasVisible = _orchestrator.isCallScreenVisible;
      _orchestrator.session.cleanUp();
      if (wasVisible || Get.currentRoute == '/CallScreen' || Get.currentRoute == '/call-screen' || Get.currentRoute == '/call') {
        if (Get.isDialogOpen ?? false) Get.back();
        Get.back();
      }
    } catch (e) {
      await endCall();
    }
  }

  Future<void> handleCallAccepted(String answerSdp) async {
    _orchestrator.session.stopRingtone();
    _orchestrator.session.ringingTimer?.cancel();
    _orchestrator.status.value = 'ongoing';
    _orchestrator.durationSeconds.value = 0;

    final acceptedMillis = DateTime.now().millisecondsSinceEpoch;
    LocalNotificationService.cancelIncomingCallNotification(_orchestrator.sessionId!);
    _orchestrator.session.startCallTimer();
    _orchestrator.session.showOngoingNotification(startedAtMillis: acceptedMillis);

    try {
      await _orchestrator.webrtcService.setRemoteAnswer(answerSdp);
    } catch (e) {}
  }

  Future<void> checkCurrentActiveCallSession() async {
    try {
      final response = await _apiClient.get(AppUrls.currentCallSession, handleError: false, showErrorScreen: false);
      if (response.isSuccess && response.body != null) {
        final bodyMap = response.body;
        final session = bodyMap is Map 
            ? (bodyMap['data'] is Map 
                ? (bodyMap['data']['session'] ?? (bodyMap['data']['id'] != null ? bodyMap['data'] : null))
                : (bodyMap['session'] ?? (bodyMap['id'] != null ? bodyMap : null)))
            : null;
        if (session != null) {
          final sessionStatus = session['status']?.toString();
          if (sessionStatus == 'ongoing' || sessionStatus == 'ringing' || sessionStatus == 'dialing' || sessionStatus == 'waiting') {
            _orchestrator.session.isSummaryShown = false;
            _orchestrator.session.sessionId = int.tryParse(session['id']?.toString() ?? '');
            _orchestrator.webrtcService.activeSessionId = _orchestrator.sessionId;
            _orchestrator.status.value = sessionStatus!;
            
            _orchestrator.session.isPackageCall = (session['is_prepaid'] == true ||
                session['is_package_session'] == true ||
                session['billing_mode'] == 'prepaid' ||
                (bodyMap is Map && (
                  bodyMap['is_prepaid'] == true ||
                  bodyMap['is_package_session'] == true ||
                  bodyMap['billing_mode'] == 'prepaid' ||
                  bodyMap['data']?['is_prepaid'] == true ||
                  bodyMap['data']?['is_package_session'] == true ||
                  bodyMap['data']?['billing_mode'] == 'prepaid'
                )));
            
            _orchestrator.session.providerId = int.tryParse(session['provider_id']?.toString() ?? '');
            final provider = session['provider'];
            _orchestrator.session.providerName = provider?['name']?.toString() ?? 'Astrologer';
            _orchestrator.session.providerImage = provider?['image']?.toString() ?? provider?['profile_image']?.toString() ?? '';
            
            if (sessionStatus == 'ongoing') {
              final startedAtStr = session['started_at']?.toString();
              if (startedAtStr != null) {
                final startedAt = DateTime.tryParse(startedAtStr)?.toLocal();
                if (startedAt != null) {
                  _orchestrator.durationSeconds.value = DateTime.now().difference(startedAt).inSeconds;
                  _orchestrator.session.startCallTimer();
                }
              }
              
              final answer = session['answer']?.toString() ?? session['answer_sdp']?.toString();
              if (answer != null && answer.isNotEmpty) {
                await _orchestrator.webrtcService.createOffer(_orchestrator.sessionId!);
                await _orchestrator.webrtcService.setRemoteAnswer(answer);
              }
            } else if (sessionStatus == 'ringing' || sessionStatus == 'dialing') {
              _orchestrator.session.startRingtone(isIncoming: false);
              _orchestrator.session.startRingingTimeout();
            }
            
            final minutes = (_orchestrator.durationSeconds.value ~/ 60).toString().padLeft(2, '0');
            final seconds = (_orchestrator.durationSeconds.value % 60).toString().padLeft(2, '0');
            LocalNotificationService.showOngoingCallNotification(
              sessionId: _orchestrator.sessionId!,
              title: '${_orchestrator.session.providerName} • Call',
              body: 'Tap to return to call session',
              startedAtMillis: () {
                if (sessionStatus == 'ongoing' && session['started_at'] != null) {
                  String isoUtc = session['started_at'].toString().trim().replaceAll(' ', 'T');
                  if (!isoUtc.endsWith('Z') && !isoUtc.contains('+') && !isoUtc.contains('-')) isoUtc += 'Z';
                  return DateTime.tryParse(isoUtc)?.toLocal().millisecondsSinceEpoch;
                }
                return null;
              }(),
            );

            if (!_orchestrator.isCallScreenVisible) {
              FloatingCallBubble.show(
                context: Get.context!,
                sessionId: _orchestrator.sessionId!,
                name: _orchestrator.session.providerName!,
                imageUrl: _orchestrator.session.providerImage ?? "",
                startedAt: session['started_at']?.toString(),
                status: _orchestrator.status.value,
                onTap: () {
                  FloatingCallBubble.dismiss();
                  Get.toNamed(AppRoutes.callScreen);
                },
              );
            }
          } else {
            _orchestrator.session.cleanUp();
          }
        } else {
          _orchestrator.session.cleanUp();
        }
      } else {
        _orchestrator.session.cleanUp();
      }
    } catch (e) {}
  }
}
