import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astro_user/routes/route_helper.dart';
import 'package:astro_user/core/constants/app_strings.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:astro_user/core/widgets/custom_button.dart';
import 'package:astro_user/features/auth/presentation/controllers/auth_controller.dart';

class NameSetupScreen extends StatelessWidget {
  const NameSetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final errorMessage = ''.obs;
    
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Back Button
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.fieldBackground,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.primaryColor),
                ),
              ),
              
              const SizedBox(height: 40),
              
              AppText(
                AppStrings.nameTitle,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 38,
                  fontWeight: FontWeight.w400,
                  color: AppColors.deepPink,
                  height: 1.1,
                ),
              ),
              
              const SizedBox(height: 12),
              
              AppText(
                AppStrings.nameSubtitle,
                fontSize: 16,
                color: AppColors.black.withOpacity(0.4),
                fontWeight: FontWeight.w400,
              ),
              
              const SizedBox(height: 50),

              // Premium Styled TextField
              Container(
                decoration: BoxDecoration(
                  color: AppColors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: TextField(
                  controller: authController.nameController,
                  onChanged: (value) {
                    // Clear error when user starts typing
                    if (errorMessage.value.isNotEmpty) {
                      errorMessage.value = '';
                    }
                  },
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textColorPrimary),
                  decoration: InputDecoration(
                    hintText: AppStrings.nameHint,
                    hintStyle: TextStyle(color: AppColors.black.withOpacity(0.2)),
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.deepPink),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppColors.black.withOpacity(0.05)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppColors.black.withOpacity(0.05)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: AppColors.deepPink, width: 2.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                ),
              ),
              
              // Error message
              Obx(() => errorMessage.value.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: AppText(
                        errorMessage.value,
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : const SizedBox.shrink()),
              
              const Spacer(),

              // Premium Gradient Button
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: CustomButton(
                  text: AppStrings.next,
                  onTap: () {
                    // Validate name before proceeding
                    if (authController.nameController.text.trim().isEmpty) {
                      errorMessage.value = AppStrings.pleaseEnterName;
                      return;
                    }
                    
                    if (authController.nameController.text.trim().length < 2) {
                      errorMessage.value = AppStrings.nameMinLength;
                      return;
                    }
                    
                    // Clear error and proceed
                    errorMessage.value = '';
                    Get.toNamed(RouteHelper.getGenderSetupRoute());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
