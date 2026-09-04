import 'package:astro_user/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:astro_user/core/constants/app_strings.dart';
import 'package:astro_user/core/constants/image_constants.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:astro_user/core/widgets/loading_widget.dart';
import 'package:astro_user/core/widgets/custom_button.dart';
import 'package:astro_user/features/auth/presentation/controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final errorMessage = ''.obs;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Stack(
        children: [
          // Fixed white background layer
          Positioned.fill(
            child: Container(color: Colors.white),
          ),
          // Background image - Stays fixed behind everything
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(
                ImageConstants.loginBackground,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Zodiac Wheel Logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          ImageConstants.app_Logo,
                          width: 170,
                          height: 170,
                        ),
                      ),
                      
                      const SizedBox(height: 30),

                      Column(
                        children: [
                          AppText(
                            AppStrings.suryaPathTitle,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepPink,
                            height: 1.2,
                            textAlign: TextAlign.center,
                          ),
                          AppText(
                            "${AppStrings.and.trim()} ${AppStrings.lifeGuidanceMatrimony}",
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepPink,
                            height: 1.2,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),


                      const SizedBox(height: 20),
                      
                      // Login using OTP text
                      AppText(
                        AppStrings.loginWithOtp,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.errorColor,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Phone Input
                      _buildPhoneInput(authController, errorMessage),
                      
                      // Error message
                      Obx(() => errorMessage.value.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8, left: 20),
                              child: AppText(
                                errorMessage.value,
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : const SizedBox.shrink()),
                      
                      const SizedBox(height: 30),
                      
                      // Send OTP Button
                      Obx(() => CustomButton(
                        text: AppStrings.sendOtp,
                        isLoading: authController.isLoading.value,
                        onTap: () {
                          // Validate mobile number before proceeding
                          if (authController.mobileController.text.isEmpty) {
                            errorMessage.value = AppStrings.pleaseEnterMobile;
                            return;
                          }
                          
                          if (authController.mobileController.text.length != 10) {
                            errorMessage.value = AppStrings.enterValidMobile;
                            return;
                          }
                          
                          // Clear error and proceed
                          errorMessage.value = '';
                          authController.login();
                        },
                      )),
                      
                      const SizedBox(height: 15),

                      // OR with lines
                      Row(
                        children: [
                          const Expanded(child: Divider(thickness: 1, color: Colors.black12)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: AppText(
                              AppStrings.or,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black26,
                              letterSpacing: 1,
                            ),
                          ),
                          const Expanded(child: Divider(thickness: 1, color: Colors.black12)),
                        ],
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Continue with Google Button
                      _buildGoogleButton(),
                      
                      const SizedBox(height: 30),
                      
                      // Bottom Features
                      _buildBottomFeatures(),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );

  }

  Widget _buildZodiacSymbol(String symbol, double size) {
    return Opacity(
      opacity: 0.12,
      child: AppText(
        symbol,
        fontSize: size,
        color: Colors.white,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget _buildPhoneInput(AuthController authController, RxString errorMessage) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              AppText(
                AppStrings.countryCodePrefix,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextFormField(
                  controller: authController.mobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  onChanged: (value) {
                    // Clear error when user starts typing
                    if (errorMessage.value.isNotEmpty) {
                      errorMessage.value = '';
                    }
                  },
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.enterMobile,
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.black26,
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                    counterText: "",
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.black12,
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.black12,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            ImageConstants.googleIcon,
            width: 28,
            height: 28,
          ),
          const SizedBox(width: 12),
          AppText(
            AppStrings.continueWithGoogle,
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomFeatures() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(25),
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
              Colors.white.withOpacity(0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: IntrinsicHeight( // Important
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _buildFeatureItem(
                  icon: Iconsax.user_copy,
                  title: AppStrings.expert,
                  subtitle: AppStrings.lifeGuidance,
                  color: AppColors.deepPink,
                ),
              ),

              _buildDivider(),

              Expanded(
                child: _buildFeatureItem(
                  icon: Iconsax.lock_copy,
                  title: AppStrings.oneHundredPercent,
                  subtitle: AppStrings.privateConfidential,
                  color: AppColors.deepPink,
                ),
              ),

              _buildDivider(),

              Expanded(
                child: _buildFeatureItem(
                  icon: Iconsax.people_copy,
                  title: AppStrings.verify,
                  subtitle: AppStrings.verifiedMatrimony,
                  color: AppColors.deepPink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Center Divider
  Widget _buildDivider() {
    return VerticalDivider(
      width: 20,
      thickness: 1,
      color: Colors.black12,
    );
  }




  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,

      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: color,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppText(
          title,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF8B1538),
        ),
        const SizedBox(height: 2),
        AppText(
          subtitle,
          textAlign: TextAlign.center,
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF8B1538),
          height: 1.2,
        ),
      ],
    );
  }
}