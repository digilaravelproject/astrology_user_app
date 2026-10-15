import 'package:astro_user/core/constants/app_constants.dart';
import 'package:astro_user/core/theme/dark_theme.dart';
import 'package:astro_user/core/theme/light_theme.dart';
import 'package:astro_user/core/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'core/theme/theme_controller.dart';
import 'features/language/presentation/controllers/localization_controller.dart';
import 'init_app.dart';
import 'routes/route_helper.dart';
import 'core/bindings/initial_bindings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:astro_user/core/services/local_notification_service.dart';
import 'package:astro_user/core/services/foreground_task_service.dart';
import 'package:astro_user/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_user/features/call/presentation/widgets/floating_call_bubble.dart';

import 'features/chat/presentation/widgets/overlay_main.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await LocalNotificationService.initialize();
    try { await ForegroundTaskService.init(); } catch (_) {}
    final data = message.data;
    final title = message.notification?.title ?? data['title']?.toString() ?? '';
    final type = data['type']?.toString();
    final String? reason = data['reason']?.toString().toLowerCase();
    final rawId = data['session_id'] ?? data['id'] ?? data['chat_session_id'] ?? data['call_session_id'];
    final int parsedSessionId = int.tryParse(rawId?.toString() ?? '') ?? 0;

    if (title.contains('Chat Ended') ||
        title.contains('Cancelled') ||
        reason == 'cancelled' ||
        reason == 'rejected' ||
        type == 'chat_ended' ||
        type == 'CHAT_ENDED' ||
        type == 'session_ended' ||
        type == 'chat_summary' ||
        type == 'CHAT_MISSED' ||
        type?.toLowerCase() == 'chat_dismissed' ||
        type?.toLowerCase() == 'chat_cancelled' ||
        type?.toLowerCase() == 'chat_rejected') {
      await LocalNotificationService.cancelOngoingChatNotification(parsedSessionId > 0 ? parsedSessionId : null);
      try { FloatingChatBubble.dismiss(stopForegroundService: true); } catch (_) {}
      try { await ForegroundTaskService.stopService(); } catch (_) {}
    } else if (title.contains('Call Ended') ||
        title.contains('Call Dismissed') ||
        title.contains('Call Cancelled') ||
        title.contains('Call Rejected') ||
        type == 'call_ended' ||
        type == 'CALL_ENDED' ||
        type == 'session_completed' ||
        type == 'session_ended' ||
        type == 'call_dismissed' ||
        type == 'call_cancelled' ||
        type == 'call_rejected') {
      await LocalNotificationService.cancelOngoingCallNotification(parsedSessionId > 0 ? parsedSessionId : null);
      try { FloatingCallBubble.dismiss(stopForegroundService: true); } catch (_) {}
      try { await ForegroundTaskService.stopService(); } catch (_) {}
    }
    if (data.containsKey('session')) {
      final sessionData = data['session'] is String 
          ? jsonDecode(data['session']) 
          : data['session'];
      final callerData = data['callerData'] is String 
          ? jsonDecode(data['callerData']) 
          : data['callerData'];
          
      final sessionId = int.tryParse(sessionData?['id']?.toString() ?? '') ?? 0;
      final consumerName = callerData?['name']?.toString() ?? 'User';
      
      if (sessionId > 0) {
        await LocalNotificationService.showIncomingCallNotification(
          sessionId: sessionId,
          title: 'Incoming Call',
          body: 'Call from $consumerName',
        );
      }
    }
  } catch (e) {
    debugPrint('Background message handling error: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.top,
    SystemUiOverlay.bottom,
  ]);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await initApp();
  runApp(const MyApp());
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OverlayChatBubbleApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    final LocalizationController localizationController = Get.find();

    return Obx(() => GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key,
      scaffoldMessengerKey: CustomSnackbar.messengerKey,
      initialBinding: InitialBindings(),
      // theme: lightTheme,
      // darkTheme: lightTheme,
      // themeMode: ThemeMode.light,
      initialRoute: '${RouteHelper.getSplashRoute()}',
      getPages: RouteHelper.routes,
      defaultTransition: Transition.fadeIn,
      locale: Locale(
        localizationController.languages[localizationController.selectedIndex].languageCode,
        localizationController.languages[localizationController.selectedIndex].countryCode,
      ),
      fallbackLocale: const Locale('en', 'US'),
      translations: Get.find<Translations>(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: localizationController.languages
          .map((lang) => Locale(lang.languageCode!, lang.countryCode!))
          .toList(),
      builder: (context, child) {
        return SafeArea(
          top: false,
          bottom: true,
          child: child ?? const SizedBox(),
        );
      },
    ));
  }
}
