import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/route_helper.dart';
import '../../../core/widgets/gender_selection_card.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/auth_controller.dart';

class GenderSetupScreen extends StatefulWidget {
  const GenderSetupScreen({Key? key}) : super(key: key);

  @override
  State<GenderSetupScreen> createState() => _GenderSetupScreenState();
}

class _GenderSetupScreenState extends State<GenderSetupScreen> {
  String selectedGender = "";
  final errorMessage = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
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
              
              const SizedBox(height: 30),
              
              AppText(
                AppStrings.genderTitle,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 38,
                  fontWeight: FontWeight.w400,
                  color: AppColors.deepPink,
                  height: 1.1,
                ),
              ),
              
              const SizedBox(height: 12),
              
              AppText(
                AppStrings.genderSubtitle,
                fontSize: 16,
                color: AppColors.black.withOpacity(0.4),
                fontWeight: FontWeight.w400,
              ),
              
              const SizedBox(height: 50),
              
              // Gender Grid
              Row(
                children: [
                  Expanded(
                    child: GenderSelectionCard(
                      label: AppStrings.male,
                      icon: Icons.male_rounded,
                      isSelected: selectedGender == "male",
                      onTap: () {
                        setState(() => selectedGender = "male");
                        // Clear error when gender is selected
                        if (errorMessage.value.isNotEmpty) {
                          errorMessage.value = '';
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GenderSelectionCard(
                      label: AppStrings.female,
                      icon: Icons.female_rounded,
                      isSelected: selectedGender == "female",
                      onTap: () {
                        setState(() => selectedGender = "female");
                        // Clear error when gender is selected
                        if (errorMessage.value.isNotEmpty) {
                          errorMessage.value = '';
                        }
                      },
                    ),
                  ),
                ],
              ),
              
              // Error message
              Obx(() => errorMessage.value.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: AppText(
                        errorMessage.value,
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink()),
              
              const SizedBox(height: 60),

              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: CustomButton(
                  text: AppStrings.next,
                  onTap: () {
                    if (selectedGender.isNotEmpty) {
                      errorMessage.value = '';
                      Get.find<AuthController>().selectedGender.value = selectedGender;
                      Get.toNamed(RouteHelper.getBirthDetailsRoute());
                    } else {
                      errorMessage.value = AppStrings.selectGenderError;
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
