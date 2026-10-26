import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_user/core/services/storage/shared_prefs.dart';
import 'package:astro_user/core/constants/app_constants.dart';
import 'package:astro_user/routes/route_helper.dart';
import 'package:astro_user/features/splash/data/datasources/splash_service.dart';
import 'package:astro_user/core/services/websocket/websocket_service.dart';
import 'package:astro_user/core/services/fcm_notification_service.dart';
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

      // Wait for 5 seconds to show splash screen
      await Future.delayed(const Duration(seconds: 5));

      // Check permissions
      bool cameraGranted = await Permission.camera.isGranted;
      bool micGranted = await Permission.microphone.isGranted;
      bool notifGranted = await Permission.notification.isGranted;

      if (cameraGranted && micGranted && notifGranted) {
        if (isReady) {
          // Check if user is logged in
          final isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;

          if (isLoggedIn) {
            Get.find<WebSocketService>().connect();
            FCMNotificationService.registerDeviceToken(null);
            Get.offAllNamed(RouteHelper.getDashboardRoute());
            // DashboardScreen.initState() will consume FCMNotificationService.pendingLiveSessionId
            // with a guaranteed postFrameCallback + 500 ms delay — no race condition here.
          } else {
            Get.offAllNamed(RouteHelper.getLoginRoute());
          }
        } else {
          // Handle maintenance or version issues
          // For now, just navigate to login
          Get.offAllNamed(RouteHelper.getLoginRoute());
        }
      } else {
        // Go to permission screen
        Get.offAllNamed(RouteHelper.getPermissionRoute());
      }
    } catch (e) {
      // Handle errors
      Get.offAllNamed(RouteHelper.getLoginRoute());
    } finally {
      isLoading.value = false;
    }
  }
}
