import 'dart:convert';
import 'package:get/get.dart';
import 'package:astro_user/core/utils/logger.dart';
import 'package:astro_user/core/services/foreground_task_service.dart';
import 'package:astro_user/core/services/local_notification_service.dart';
import 'package:astro_user/core/constants/app_constants.dart';
import 'package:astro_user/routes/route_helper.dart';
import 'package:astro_user/core/services/websocket/websocket_service.dart';

import '../../../utils/custom_snackbar.dart';
import '../../storage/shared_prefs.dart';
import '../../storage/token_manger.dart';

class AuthWsHandler {
  static void handleForceLoggedOut(dynamic rawData) async {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        try {
          eventData = jsonDecode(rawData);
        } catch (_) {}
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final String message =
          eventData['message']?.toString() ??
          'Your account was logged in on another device. Please log in again.';

      if (Get.isRegistered<WebSocketService>()) {
        Get.find<WebSocketService>().disconnect();
      }

      try {
        ForegroundTaskService.stopService();
        LocalNotificationService.cancelOngoingChatNotification(null);
        LocalNotificationService.cancelOngoingCallNotification(null);
      } catch (_) {}

      SharedPrefs.remove(AppConstants.userData);
      SharedPrefs.setBool(AppConstants.isLoggedIn, false);
      await TokenManager.clearToken();

      CustomSnackbar.showError(message);

      if (Get.currentRoute != RouteHelper.getLoginRoute()) {
        Get.offAllNamed(RouteHelper.getLoginRoute());
      }
    } catch (e) {
      Logger.e('AuthWsHandler: Error handling force logout: $e');
    }
  }
}
