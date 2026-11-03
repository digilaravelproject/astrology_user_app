import 'dart:async';
import 'package:get/get.dart';
import 'package:astro_user/core/services/storage/shared_prefs.dart';
import 'package:astro_user/core/constants/app_constants.dart';
import 'package:astro_user/routes/route_helper.dart';
import 'package:astro_user/routes/app_routes.dart';
import 'package:astro_user/features/splash/data/datasources/splash_service.dart';
import 'package:astro_user/core/services/websocket/websocket_service.dart';
import 'package:astro_user/core/services/fcm_notification_service.dart';
import 'package:astro_user/core/services/cold_start_detector.dart';
import 'package:astro_user/core/bindings/initial_bindings.dart';
import 'package:astro_user/features/call/presentation/controllers/call_controller.dart';
import 'package:astro_user/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_user/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_user/features/live/presentation/pages/live_room_screen.dart';
import 'package:astro_user/features/chat_assistance/presentation/pages/chat_assistance_screen.dart';
import 'package:astro_user/features/chat_assistance/presentation/bindings/chat_assistance_binding.dart';
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

      // ── FAST PATH: Cold-Start Communication (Call/Chat/Live) ────────────
      final intent = ColdStartDetector.currentIntent;
      final isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;

      if (isLoggedIn && intent != null && intent.type != ColdStartType.none) {
        print('[SPLASH] Cold-start communication intent detected: ${intent.type} (sessionId=${intent.sessionId}). Executing ZERO-LAG fast path.');
        ColdStartDetector.currentIntent = null; // consume

        // Connect WebSocket in background immediately
        try {
          if (Get.isRegistered<WebSocketService>()) {
            Get.find<WebSocketService>().connect();
          } else {
            Get.put(WebSocketService(), permanent: true).connect();
          }
        } catch (e) {
          print('[SPLASH] WebSocket fast path connect error: $e');
        }

        try {
          FCMNotificationService.registerDeviceToken(null);
        } catch (_) {}

        if (intent.type == ColdStartType.call) {
          _dispatchColdStartCall(intent);
        } else if (intent.type == ColdStartType.chat) {
          _dispatchColdStartChat(intent);
        } else if (intent.type == ColdStartType.live) {
          _dispatchColdStartLive(intent);
        } else if (intent.type == ColdStartType.assistanceChat) {
          _dispatchColdStartAssistance(intent);
        }
        return;
      }

      // Initialize splash service
      final isReady = await _splashService.initialize();

      // If opening from a push notification (live/call/chat), skip delay; otherwise 2 seconds splash
      if (FCMNotificationService.pendingLiveSessionId == null &&
          FCMNotificationService.pendingNotificationData == null) {
        await Future.delayed(const Duration(seconds: 2));
      }

      // Check permissions
      bool cameraGranted = await Permission.camera.isGranted;
      bool micGranted = await Permission.microphone.isGranted;
      bool notifGranted = await Permission.notification.isGranted;

      if (cameraGranted && micGranted && notifGranted) {
        if (isReady) {
          // Check if user is logged in
          if (isLoggedIn) {
            try {
              if (Get.isRegistered<WebSocketService>()) {
                Get.find<WebSocketService>().connect();
              } else {
                Get.put(WebSocketService(), permanent: true).connect();
              }
            } catch (e) {
              print('[SPLASH] WebSocket init error: $e');
            }
            try {
              FCMNotificationService.registerDeviceToken(null);
            } catch (_) {}
            final String currentRoute = Get.currentRoute.toLowerCase();
            final bool isCommunicationActive = currentRoute.contains('call') ||
                currentRoute.contains('chat') ||
                currentRoute.contains('live');

            if (!isCommunicationActive) {
              Get.offAllNamed(RouteHelper.getDashboardRoute());
            } else {
              print('[SPLASH] Communication screen already active ($currentRoute). Preserving stack.');
            }
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
      print('[SPLASH] Error during initialization: $e');
      final isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
      if (isLoggedIn) {
        Get.offAllNamed(RouteHelper.getDashboardRoute());
      } else {
        Get.offAllNamed(RouteHelper.getLoginRoute());
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _dispatchColdStartCall(ColdStartIntent intent) {
    if (!Get.isRegistered<CallController>()) {
      InitialBindings().dependencies();
    }
    final ctrl = Get.find<CallController>();
    ctrl.sessionId = intent.sessionId;
    ctrl.isAcceptedLocally = true;
    ctrl.isCallScreenVisible = true;
    if (intent.name != null && intent.name!.isNotEmpty) {
      ctrl.providerName = intent.name;
    }
    // Directly replace Splash with CallScreen
    Get.offAllNamed(AppRoutes.callScreen);
  }

  void _dispatchColdStartChat(ColdStartIntent intent) {
    final astroName = intent.name?.isNotEmpty == true ? intent.name! : 'Astrologer';
    final astroImage = intent.avatar ?? '';
    final chatScreen = ChatScreen(
      astrologerName: astroName,
      astrologerImage: astroImage,
      sessionId: intent.sessionId,
      initialStatus: 'ongoing',
    );
    // Directly replace Splash with ChatScreen
    Get.offAll(() => chatScreen, binding: ChatBinding());
  }

  void _dispatchColdStartLive(ColdStartIntent intent) {
    final astroName = intent.name?.isNotEmpty == true ? intent.name! : 'Astrologer';
    final astroImage = intent.avatar ?? '';
    Get.offAll(() => LiveRoomScreen(
      sessionId: intent.sessionId,
      astrologerName: astroName,
      astrologerImage: astroImage,
    ));
  }

  void _dispatchColdStartAssistance(ColdStartIntent intent) {
    Get.offAll(
      () => const ChatAssistanceScreen(),
      binding: ChatAssistanceBinding(),
    );
  }
}
