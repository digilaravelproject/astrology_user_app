import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/services/DynamicAppIcon/dynamic_app_icon_manager.dart';
import 'core/services/config/env_config.dart';
import 'core/services/notification/notification_service.dart';
import 'features/language/controllers/localization_controller.dart';
import 'core/theme/theme_controller.dart';
import 'core/services/storage/shared_prefs.dart';
import 'translations/translations.dart';

Future<void> initApp() async {
  // Set environment configuration
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  // EnvConfig.setEnvironment(Environment.development); // Change as needed

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('🔥 [Firebase] Initialized successfully.');
  } catch (e) {
    debugPrint('⚠️ [Firebase] Initialization note/error: $e');
  }

  // Initialize notification service
  await NotificationService.instance.initialize();


  // Initialize dynamic app icon manager
  // await DynamicAppIconManager.init();


  // Initialize shared preferences
  await SharedPrefs.init();

  // Register controllers
  // Get.lazyPut(() => ThemeController());
  Get.put(ThemeController()); // instead of Get.lazyPut

  Get.lazyPut(() => LocalizationController());

  // Initialize theme
  // await Get.find<ThemeController>().initTheme();

  // Initialize language
  await Get.find<LocalizationController>().initLanguage();

  // Initialize translations
  AppTranslations translations = await AppTranslations.load();
  Get.put<Translations>(translations);


}
