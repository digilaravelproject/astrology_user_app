import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_user/core/services/webrtc/webrtc_service.dart';
import 'package:astro_user/core/services/websocket/websocket_service.dart';
import 'call_session_controller.dart';
import 'call_webrtc_controller.dart';

class CallController extends GetxController {
  final CallSessionController session;
  final CallWebRTCController webrtc;
  final WebRTCService webrtcService = WebRTCService();

  CallController({required this.session, required this.webrtc});

  RxString get status => session.status;
  RxInt get durationSeconds => session.durationSeconds;
  
  bool get isCallScreenVisible => session.isCallScreenVisible;
  set isCallScreenVisible(bool val) => session.isCallScreenVisible = val;

  int? get sessionId => session.sessionId;
  String? get providerName => session.providerName;
  String? get providerImage => session.providerImage;
  int? get providerId => session.providerId;
  bool get isPackageCall => session.isPackageCall;
  bool get isChatAlsoActive => session.isChatAlsoActive;
  RxBool isMuted = false.obs;
  RxBool isSpeakerOn = false.obs;

  int get packageMasterSeconds => WebSocketService.packageRemainingSeconds.value;

  void toggleMute() {
    isMuted.value = !isMuted.value;
    webrtcService.toggleMute(isMuted.value);
  }

  void toggleSpeaker() {
    isSpeakerOn.value = !isSpeakerOn.value;
    webrtcService.toggleSpeaker(isSpeakerOn.value);
  }

  Future<void> initiateCall({
    required int providerId,
    required String providerName,
    required String providerImage,
    bool isPackageSession = false,
  }) => webrtc.initiateCall(
    providerId: providerId,
    providerName: providerName,
    providerImage: providerImage,
    isPackageSession: isPackageSession,
  );

  Future<void> cancelCall() => webrtc.cancelCall();
  Future<void> endCall() => webrtc.endCall();
  Future<void> terminateChannelOnly() => webrtc.terminateChannelOnly();
  Future<void> terminateEntireSession() => webrtc.terminateEntireSession();
  
  void minimizeToBubble(BuildContext context, String name, String image, {bool shouldPop = true}) {
    session.minimizeToBubble(context, name, image, shouldPop: shouldPop);
  }

  void cleanUp() => session.cleanUp();
  Future<void> checkCurrentActiveCallSession() => webrtc.checkCurrentActiveCallSession();
}
