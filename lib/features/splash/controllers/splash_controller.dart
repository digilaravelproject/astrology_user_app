import 'dart:async';
import 'package:get/get.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/notification/notification_service.dart';
import '../../../routes/route_helper.dart';
import '../domain/services/splash_service.dart';

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

        // Check if user is logged in
        final isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;

        if (isLoggedIn) {
          await Get.offAllNamed(RouteHelper.getHomeRoute());
        } else {
          await Get.offAllNamed(RouteHelper.getLoginRoute());
        }
        // Check if app was opened via notification from terminated state
        await NotificationService.instance.handleTerminatedMessage();
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
