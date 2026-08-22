import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/route_helper.dart';
import '../domain/services/splash_service.dart';
import '../../../core/services/network/websocket_service.dart';
import '../../../core/services/fcm_notification_service.dart';
import '../../../features/live/presentation/pages/live_room_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashController extends GetxController {
  final SplashService _splashService;

  SplashController(this._splashService);

  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    initApp();
  }

  Future<void> initApp() async {
    try {
      isLoading.value = true;

      // Initialize splash service
      final isReady = await _splashService.initialize();

      if (isReady) {
        // Wait for 5 seconds to show splash screen
        await Future.delayed(const Duration(seconds: 5));

        // Check permissions
        bool cameraGranted = await Permission.camera.isGranted;
        bool micGranted = await Permission.microphone.isGranted;
        bool notifGranted = await Permission.notification.isGranted;

        if (cameraGranted && micGranted && notifGranted) {
          // Check if user is logged in
          final isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;

          if (isLoggedIn) {
            Get.find<WebSocketService>().connect();
            FCMNotificationService.registerDeviceToken(null);
            Get.offAllNamed(RouteHelper.getDashboardRoute());

            // ── Consume pending cold-start notification ──────────────────────
            // After Dashboard is loaded, navigate to the target screen.
            final pendingSessionId = FCMNotificationService.pendingLiveSessionId;
            final pendingData = FCMNotificationService.pendingNotificationData;
            if (pendingSessionId != null) {
              // Clear the pending intent so it isn't consumed again
              FCMNotificationService.pendingLiveSessionId = null;
              FCMNotificationService.pendingNotificationData = null;

              final astrologerName =
                  pendingData?['astrologer_name']?.toString() ?? 'Astrologer';
              final astrologerImage =
                  pendingData?['astrologer_avatar']?.toString() ??
                  pendingData?['astrologer_image']?.toString() ??
                  '';

              // Short delay so the Dashboard widget tree is fully built
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  Get.to(() => LiveRoomScreen(
                    sessionId: pendingSessionId,
                    astrologerName: astrologerName,
                    astrologerImage: astrologerImage,
                  ));
                });
              });
            }
            // ──────────────────────────────────────────────────────────────────────────────
          } else {
            Get.offAllNamed(RouteHelper.getLoginRoute());
          }
        } else {
          // Go to permission screen
          Get.offAllNamed(RouteHelper.getPermissionRoute());
        }
      } else {
        // Handle maintenance or version issues
        // For now, just navigate to login
        Get.offAllNamed(RouteHelper.getLoginRoute());
      }
    } catch (e) {
      // Handle errors
      Get.offAllNamed(RouteHelper.getLoginRoute());
    } finally {
      isLoading.value = false;
    }
  }
}
