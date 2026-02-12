import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/image_constants.dart';
import '../../../core/utils/styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../routes/route_helper.dart';
import '../../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../../../core/constants/app_strings.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Dark icons for white background
        statusBarBrightness: Brightness.light, // For iOS
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // 1. Subtle Zodiac Background Watermarks
            _buildBackgroundWatermarks(),

            // 2. Main Content
            SafeArea(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * 0.02),

                      // Logo with soft container and spiritual aura
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFFF8F00).withOpacity(0.15),
                                  const Color(0xFFFF8F00).withOpacity(0),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF8F00).withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const AppLogo(size: 85),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),
                      
                      SizedBox(height: size.height * 0.05),

                      // Catchphrase: First talk with astrologer is Free
                      Text(
                        AppStrings.loginTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2D2D2D), // Warm charcoal
                          fontFamily: 'Playfair Display',
                          height: 1.2,
                          letterSpacing: -0.2,
                        ),
                      ),

                      SizedBox(height: size.height * 0.05),

                      // Refined Simple Phone Input Section
                      Form(
                        key: authController.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.loginWithOtp,
                              style: TextStyle(
                                color: Color(0xFFFF6D00),
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Playfair Display',
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 25),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 0),
                              padding: const EdgeInsets.only(bottom: 2),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.transparent, // Replaced by gradient below
                                    width: 1.2,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        '+ 91',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF424242),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: TextFormField(
                                          controller: authController.mobileController,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          style: const TextStyle(
                                            fontSize: 16, 
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 1,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: AppStrings.enterMobile,
                                            hintStyle: TextStyle(
                                              color: Colors.black38, 
                                              fontSize: 15,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            counterText: "",
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                            errorStyle: TextStyle(
                                              color: Color(0xFFD32F2F),
                                              fontSize: 11,
                                              height: 0.8,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            errorBorder: InputBorder.none,
                                            focusedErrorBorder: InputBorder.none,
                                          ),
                                          validator: authController.validateMobile,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 1.2,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFFFF8F00).withOpacity(0.5),
                                          const Color(0xFFFF8F00),
                                          const Color(0xFFD32F2F).withOpacity(0.7),
                                        ],
                                        stops: const [0.0, 0.6, 1.0],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: size.height * 0.05),
                            
                            // Reference-matching Pill Send Button
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                              child: GestureDetector(
                                onTap: authController.login,
                                child: Container(
                                  width: double.infinity,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF8F00), // Bhagwa
                                        Color(0xFFFF6D00), // Bhagwa
                                        Color(0xFFD32F2F), // Red (30%)
                                      ],
                                      stops: [0.0, 0.6, 1.0],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(27),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF8F00).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      AppStrings.sendOtp,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            // OR Divider
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.black12, thickness: 1)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    AppStrings.or,
                                    style: const TextStyle(color: Colors.black26, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.black12, thickness: 1)),
                              ],
                            ),

                            const SizedBox(height: 25),

                            // Google Login Button
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: OutlinedButton(
                                onPressed: () {
                                  // Google Login Logic Placeholder
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.black12),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  backgroundColor: Colors.white,
                                  elevation: 2,
                                  shadowColor: Colors.black.withOpacity(0.05),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.string(
                                      '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24s.92 7.54 2.56 10.78l7.97-6.19z"/>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
  <path fill="none" d="M0 0h48v48H0z"/>
</svg>''',
                                      height: 20,
                                      width: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      AppStrings.continueWithGoogle,
                                      style: TextStyle(
                                        color: Color(0xFF424242),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 35),

                      // Trust Info Section
                      _buildTrustSection(),

                      const SizedBox(height: 40),

                      // Terms & Privacy Section (Moved to last)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text.rich(
                          TextSpan(
                            text: AppStrings.byContinuing,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.35),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: AppStrings.termsOfService,
                                style: const TextStyle(
                                  color: Color(0xFFFF6D00),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: AppStrings.and),
                              TextSpan(
                                text: AppStrings.privacyPolicy,
                                style: const TextStyle(
                                  color: Color(0xFFFF6D00),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

            // Loading overlay
            Obx(() => authController.isLoading.value
                ? LoadingWidget(type: LoadingType.overlay)
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundWatermarks() {
    return Stack(
      children: [
        // Top Left
        _watermarkText("♈", 60, 20, size: 45, rotation: 0.2),
        _watermarkText("☀️", 120, -10, size: 70, rotation: 0),
        
        // Top Right
        _watermarkText("🌙", 80, 280, size: 50, rotation: -0.4),
        _watermarkText("✨", 180, 320, size: 22, rotation: 0.1),
        
        // Mid Left
        _watermarkText("♉", 380, -20, size: 65, rotation: -0.1),
        _watermarkText("✨", 450, 40, size: 18, rotation: 0.5),
        
        // Mid Right
        _watermarkText("♊", 350, 300, size: 55, rotation: 0.5),
        _watermarkText("🪐", 520, 280, size: 75, rotation: 0.2),
        
        // Bottom Sections (spread out)
        _watermarkText("♋", 650, 30, size: 60, rotation: -0.2),
        _watermarkText("✨", 750, 100, size: 25, rotation: -0.2),
        _watermarkText("♌", 850, 250, size: 90, rotation: 0.1),
        _watermarkText("♎", 950, 50, size: 65, rotation: 0.3),
        _watermarkText("🌠", 1100, 200, size: 85, rotation: -0.3),
      ],
    );
  }

  Widget _watermarkText(String symbol, double top, double left, {double size = 60, double rotation = 0}) {
    return Positioned(
      top: top,
      left: left,
      child: Transform.rotate(
        angle: rotation,
        child: Opacity(
          opacity: 0.045, // Even lighter as requested
          child: Text(
            symbol,
            style: TextStyle(
              fontSize: size,
              color: const Color(0xFFFF8F00), 
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8F00).withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTrustItem(AppStrings.expert, AppStrings.verifiedAstrologers),
          _buildVerticalDivider(),
          _buildTrustItem("100%", AppStrings.privateConfidential),
          _buildVerticalDivider(),
          _buildTrustItem(AppStrings.verify, AppStrings.privacySafety),
        ],
      ),
    );
  }

  Widget _buildTrustItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.black.withOpacity(0.5),
              fontWeight: FontWeight.w700,
              height: 1.3,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1.5,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
