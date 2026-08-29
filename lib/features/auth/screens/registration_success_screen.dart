import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/cosmic_background.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../routes/route_helper.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Success Icon (Double Circle)
              Container(
                width: size.width * 0.42,
                height: size.width * 0.42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: size.width * 0.28,
                    height: size.width * 0.28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 70,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Welcome Text
              AppText(
                AppStrings.welcome,
                fontSize: 48,
                fontWeight: FontWeight.w600, // SemiBold
                color: AppColors.deepPink,
                height: 1.1,
              ),

              const SizedBox(height: 15),

              // Success Message
              AppText(
                AppStrings.registrationSuccessful,
                fontSize: 18,
                color: AppColors.textColorSecondary,
                fontWeight: FontWeight.w400, // Regular
                letterSpacing: 0.5,
              ),

              const Spacer(flex: 3),

              // Get Started Button
              CustomButton(
                text: AppStrings.getStarted,
                onTap:
                    () => Get.offNamed(RouteHelper.getLanguageSelectionRoute()),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
