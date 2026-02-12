import 'package:astro_user/core/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/image_constants.dart';
import '../../../core/theme/theme_controller.dart';
import '../../language/controllers/localization_controller.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final splashController = Get.find<SplashController>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // White icons for dark background
        statusBarBrightness: Brightness.dark, // For iOS
      ),
      child: Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF9933), // Primary Saffron
              Color(0xFFFF6600), // Deeper Saffron
              Color(0xFF803300), // Dark Brownish Saffron
            ],
          ),
        ),
        child: Stack(
          children: [

            // Animated Zodiac Wheel
            Center(
              child: RotationTransition(
                turns: _rotationController,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.width * 0.85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    ImageConstants.zodiacWheel,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Bottom Section
            Positioned(
              bottom: 80,
              left: 40,
              right: 40,
              child: Column(
                children: [
                  Text(
                    "Discover what the stars have in store for you today.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Obx(
                    () => Visibility(
                      visible: splashController.isLoading.value,
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
