import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../storage/shared_prefs.dart';
import '../../../../routes/app_routes.dart';
import '../../../../features/notification/screens/notification_screen.dart';

/// Top-level background message handler for FCM.
/// Must be an explicit top-level function with `@pragma('vm:entry-point')`.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('🔔 [FCM 🚀 BACKGROUND] Firebase already initialized or note: $e');
  }

  debugPrint('==================== 🔔 FCM BACKGROUND MESSAGE RECEIVED ====================');
  debugPrint('🆔 Message ID : ${message.messageId}');
  debugPrint('📦 From       : ${message.from}');
  debugPrint('⏱ Sent Time  : ${message.sentTime}');
  debugPrint('🏷 Category   : ${message.category}');
  debugPrint('📊 Data       : ${jsonEncode(message.data)}');
  if (message.notification != null) {
    debugPrint('📢 Notification Title: ${message.notification?.title}');
    debugPrint('📢 Notification Body : ${message.notification?.body}');
  }
  debugPrint('============================================================================');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const String channelId = 'high_importance_channel';
  static const String channelName = 'High Importance Notifications';
  static const String channelDescription = 'This channel is used for important notifications and alerts.';

  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    channelId,
    channelName,
    description: channelDescription,
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  bool _isInitialized = false;
  String? _cachedFcmToken;
  String? _cachedApnsToken;
  AuthorizationStatus? _authStatus;

  /// Initializes Firebase messaging, permissions, local notifications, channels, and stream listeners.
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('ℹ️ [FCM 🔔 INIT] NotificationService is already initialized.');
      return;
    }

    try {
      debugPrint('🚀 [FCM 🔔 INIT] Starting NotificationService initialization...');

      // 1. Request user permission
      await _requestPermissions();

      // 2. Setup Android notification channel & local notifications plugin
      await _setupLocalNotifications();

      // 3. Configure foreground presentation options for iOS
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 4. Register FCM Stream listeners
      _setupForegroundListener();
      _setupBackgroundOpenedListener();

      // 5. Fetch and synchronize device token
      await syncToken();

      // 6. Listen to token refresh
      _fcm.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 [FCM 🔑 TOKEN] Token refreshed by FCM: $newToken');
        _handleTokenRefresh(newToken);
      }, onError: (error, stackTrace) {
        debugPrint('❌ [FCM ❌ ERROR] onTokenRefresh error: $error\n$stackTrace');
      });

      _isInitialized = true;
      debugPrint('✅ [FCM 🔔 INIT] NotificationService successfully initialized.');

      // Print full diagnostic report in debug mode
      if (kDebugMode) {
        runDiagnostics();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [FCM ❌ ERROR] Fatal initialization error: $e');
      debugPrint('Stack Trace:\n$stackTrace');
    }
  }

  /// Check and process any notification that opened the app from terminated state.
  Future<void> handleTerminatedMessage() async {
    try {
      debugPrint('🔍 [FCM 🚀 TERMINATED] Checking for cold start initial message...');
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🎯 [FCM 🚀 TERMINATED] Cold start message detected!');
        debugPrint('🆔 Message ID : ${initialMessage.messageId}');
        debugPrint('📊 Payload Data: ${jsonEncode(initialMessage.data)}');
        _handlePayloadNavigation(initialMessage.data);
      } else {
        debugPrint('ℹ️ [FCM 🚀 TERMINATED] No initial notification launch found.');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [FCM ❌ ERROR] Failed to inspect initial message: $e\n$stackTrace');
    }
  }

  /// Request Notification permissions across platforms with granular diagnostics
  Future<void> _requestPermissions() async {
    try {
      debugPrint('🔐 [FCM 🔐 PERMISSION] Requesting notification permissions...');
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      _authStatus = settings.authorizationStatus;
      debugPrint('🔐 [FCM 🔐 PERMISSION] FCM Authorization Status: ${_authStatus.toString()}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ [FCM 🔐 PERMISSION] User granted full notification permission.');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('⚠️ [FCM 🔐 PERMISSION] User granted provisional notification permission.');
      } else {
        debugPrint('⚠️ [FCM 🔐 PERMISSION] User declined or has not accepted notification permission.');
      }

      if (Platform.isAndroid) {
        final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          final granted = await androidPlugin.requestNotificationsPermission();
          debugPrint('🔐 [FCM 🔐 PERMISSION] Android 13+ (POST_NOTIFICATIONS) runtime granted: $granted');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [FCM ❌ ERROR] Error during permission request: $e\n$stackTrace');
    }
  }

  /// Setup local notifications & Android Notification Channel
  Future<void> _setupLocalNotifications() async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          await androidPlugin.createNotificationChannel(_androidChannel);
          debugPrint('📢 [FCM 🔔 CHANNEL] Android Notification Channel created: $channelId');
        }
      }

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('👆 [FCM 👆 TAP] Local notification banner tapped by user.');
          debugPrint('📦 Payload Raw: ${response.payload}');
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              Map<String, dynamic> data = jsonDecode(response.payload!);
              _handlePayloadNavigation(data);
            } catch (e) {
              debugPrint('⚠️ [FCM 👆 TAP] Payload is not valid JSON, raw text: ${response.payload}');
              _navigateToNotifications();
            }
          } else {
            _navigateToNotifications();
          }
        },
      );
      debugPrint('✅ [FCM 🔔 LOCAL] FlutterLocalNotificationsPlugin initialized.');
    } catch (e, stackTrace) {
      debugPrint('❌ [FCM ❌ ERROR] Local notification setup failed: $e\n$stackTrace');
    }
  }

  /// Setup foreground message listener
  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('==================== 📩 FCM FOREGROUND MESSAGE RECEIVED ====================');
      debugPrint('🆔 Message ID : ${message.messageId}');
      debugPrint('📦 From       : ${message.from}');
      debugPrint('📢 Title      : ${message.notification?.title}');
      debugPrint('📢 Body       : ${message.notification?.body}');
      debugPrint('📊 Data       : ${jsonEncode(message.data)}');
      debugPrint('============================================================================');

      _showLocalNotification(message);
    }, onError: (error, stackTrace) {
      debugPrint('❌ [FCM ❌ ERROR] onMessage stream error: $error\n$stackTrace');
    });
  }

  /// Setup background message click listener (when app is opened from background)
  void _setupBackgroundOpenedListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('==================== 🚀 FCM BACKGROUND APP-OPENED CLICK ====================');
      debugPrint('🆔 Message ID : ${message.messageId}');
      debugPrint('📊 Data       : ${jsonEncode(message.data)}');
      debugPrint('============================================================================');

      _handlePayloadNavigation(message.data);
    }, onError: (error, stackTrace) {
      debugPrint('❌ [FCM ❌ ERROR] onMessageOpenedApp stream error: $error\n$stackTrace');
    });
  }

  /// Shows heads-up banner using FlutterLocalNotificationsPlugin
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final data = message.data;

      String title = notification?.title ?? (data['title'] as String?) ?? 'New Notification';
      String body = notification?.body ?? (data['body'] as String?) ?? (data['message'] as String?) ?? '';

      final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notificationId,
        title,
        body,
        platformDetails,
        payload: jsonEncode(data),
      );

      debugPrint('🔔 [FCM 📩 FOREGROUND] Heads-up banner displayed locally (ID: $notificationId)');
    } catch (e, stackTrace) {
      debugPrint('❌ [FCM ❌ ERROR] Failed to display local notification: $e\n$stackTrace');
    }
  }

  /// Manually trigger a test local notification to verify device sound/vibration/HUD
  Future<void> showTestNotification({String? title, String? body}) async {
    try {
      debugPrint('🧪 [FCM 🧪 TEST] Triggering test notification...');
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        999,
        title ?? 'Test Notification 🔔',
        body ?? 'If you see this with sound and banner, Local Notifications are 100% working!',
        platformDetails,
        payload: jsonEncode({'route': '/notification', 'type': 'test'}),
      );
      debugPrint('✅ [FCM 🧪 TEST] Test notification dispatched successfully.');
    } catch (e, stackTrace) {
      debugPrint('❌ [FCM ❌ ERROR] Test notification failed: $e\n$stackTrace');
    }
  }

  /// Sync device FCM token (and APNs token on iOS)
  Future<String?> syncToken() async {
    try {
      if (Platform.isIOS) {
        _cachedApnsToken = await _fcm.getAPNSToken();
        debugPrint('🍎 [FCM 🔑 TOKEN] APNs Device Token: $_cachedApnsToken');
      }

      String? token = await _fcm.getToken();
      _cachedFcmToken = token;

      if (token != null) {
        debugPrint('🔑 [FCM 🔑 TOKEN] Active FCM Token: $token');
        await _handleTokenRefresh(token);
      } else {
        debugPrint('⚠️ [FCM 🔑 TOKEN] FCM Token returned null.');
      }
      return token;
    } catch (e, stackTrace) {
      debugPrint('❌ [FCM ❌ ERROR] Failed to retrieve FCM token: $e\n$stackTrace');
      return null;
    }
  }

  /// Saves FCM token locally and syncs with backend
  Future<void> _handleTokenRefresh(String token) async {
    try {
      _cachedFcmToken = token;
      await SharedPrefs.setString('fcm_token', token);
      debugPrint('💾 [FCM 🔑 TOKEN] FCM Token successfully cached in SharedPrefs.');
    } catch (e, stackTrace) {
      debugPrint('❌ [FCM ❌ ERROR] Failed to cache FCM token: $e\n$stackTrace');
    }
  }

  /// Navigates based on notification payload data
  void _handlePayloadNavigation(Map<String, dynamic> data) {
    try {
      if (data.isEmpty) {
        debugPrint('🧭 [FCM 🧭 ROUTE] Payload is empty -> navigating to default Notifications screen.');
        _navigateToNotifications();
        return;
      }

      final String? route = data['route'] ?? data['screen'];
      final String? type = data['type'];

      debugPrint('🧭 [FCM 🧭 ROUTE] Handling route: "$route" | Type: "$type"');

      if (route != null && route.isNotEmpty) {
        Get.toNamed(route, arguments: data);
      } else {
        _navigateToNotifications();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [FCM ❌ ERROR] Error navigating from payload: $e\n$stackTrace');
      _navigateToNotifications();
    }
  }

  void _navigateToNotifications() {
    try {
      if (Get.currentRoute != AppRoutes.splash) {
        Get.to(() => const NotificationScreen());
      }
    } catch (e) {
      debugPrint('❌ [FCM ❌ ERROR] Navigation to NotificationScreen error: $e');
    }
  }

  /// Comprehensive Diagnostic Health Check Report
  void runDiagnostics() {
    debugPrint('========================================================================');
    debugPrint('               🩺 NOTIFICATION SERVICE DIAGNOSTIC REPORT                ');
    debugPrint('========================================================================');
    debugPrint('📱 Platform                 : ${Platform.operatingSystem} (${Platform.version})');
    debugPrint('🚀 Service Initialized      : $_isInitialized');
    debugPrint('🔐 Authorization Status     : ${_authStatus ?? "Unknown / Not Requested"}');
    debugPrint('📢 Android Channel ID       : $channelId (Importance.max)');
    if (Platform.isIOS) {
      debugPrint('🍎 APNs Token               : ${_cachedApnsToken ?? "None / Waiting"}');
    }
    debugPrint('🔑 FCM Token                : ${_cachedFcmToken ?? "None / Not Fetched"}');
    debugPrint('💾 Stored SharedPrefs Token : ${SharedPrefs.getString("fcm_token") ?? "None"}');
    debugPrint('========================================================================');
  }

  /// Public Getters
  String? get fcmToken => _cachedFcmToken;
  String? get apnsToken => _cachedApnsToken;
  bool get isInitialized => _isInitialized;
}
