import '../../../core/widgets/cosmic_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/image_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/splash_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    Get.find<SplashController>();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            CosmicBackground(),


            SafeArea(
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, entryValue, child) {
                    final opacity = entryValue.clamp(0.0, 1.0);

                    return AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            (-30 * (1 - entryValue)) +
                                (entryValue >= 0.99 ? _floatAnimation.value : 0),
                          ),
                          child: Opacity(
                            opacity: opacity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                ImageConstants.app_Logo, // Apna logo/image
                                width: 220,
                                height: 220,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            /*SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 15),

                  // Surya Path Section with Animation
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, entryValue, child) {
                        final opacity = (entryValue.isNaN || entryValue.isInfinite)
                            ? 0.0
                            : entryValue.clamp(0.0, 1.0);

                        return AnimatedBuilder(
                          animation: _floatAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, (-30 * (1 - entryValue)) + (entryValue >= 0.99 ? _floatAnimation.value : 0)),
                              child: Opacity(
                                opacity: opacity,
                                child: _buildSplashCard(
                                  context: context,
                                  title: AppStrings.suryaPathSplash,
                                  imagePath: ImageConstants.suryaChariot,
                                  alignment: Alignment.bottomCenter,
                                  backgroundColor: const Color(0xFF2D1B14),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Separator with "and" pill (Reference Style)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          height: 1.2,
                          color: const Color(0xFFB3261E).withOpacity(0.3),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1400),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value.isNaN ? 0.0 : value.clamp(0.0, 1.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB3261E),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFB3261E).withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: AppText(
                                  AppStrings.andBadge,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Matrimony Section with Animation
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, entryValue, child) {
                        final opacity = (entryValue.isNaN || entryValue.isInfinite)
                            ? 0.0
                            : entryValue.clamp(0.0, 1.0);

                        return AnimatedBuilder(
                          animation: _floatAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, (30 * (1 - entryValue)) + (entryValue >= 0.99 ? -_floatAnimation.value : 0)),
                              child: Opacity(
                                opacity: opacity,
                                child: _buildSplashCard(
                                  context: context,
                                  title: AppStrings.astroApprovedMatrimony,
                                  imagePath: ImageConstants.astroMatrimony,
                                  alignment: Alignment.center,
                                  backgroundColor: AppColors.softPink,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildSplashCard({
    required BuildContext context,
    required String title,
    required String imagePath,
    required Alignment alignment,
    required Color backgroundColor,
  }) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                imagePath,
                fit: BoxFit.fitWidth,
                alignment: alignment,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFB3261E),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(90),
                    bottomRight: Radius.circular(90),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: size.width * 0.08,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 2,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
