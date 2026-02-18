import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/route_helper.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/auth_controller.dart';

class NameSetupScreen extends StatelessWidget {
  const NameSetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
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
              
              const Spacer(),

              // Premium Gradient Button
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: CustomButton(
                  text: AppStrings.next,
                  onTap: () => Get.toNamed(RouteHelper.getGenderSetupRoute()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
