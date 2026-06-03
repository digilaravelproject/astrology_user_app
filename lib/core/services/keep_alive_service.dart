import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';

Future<void> initializeKeepAliveService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      initialNotificationTitle: 'Suryapath Kundli',
      initialNotificationContent: 'Keeping your session active',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: ['dataSync'],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  // Keep the isolate alive
  Timer.periodic(const Duration(minutes: 1), (timer) {
    // Dummy timer to keep the background isolate active
  });

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}
