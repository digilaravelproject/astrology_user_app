import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/route_helper.dart';
import '../../language/controllers/localization_controller.dart';
import '../../language/domain/models/language_model.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildBackgroundPattern(context),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Back Button
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFF9933).withOpacity(0.05),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF2E1A47)),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        AppText(
                          AppStrings.selectLanguageTitle,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 38,
                            fontWeight: FontWeight.w400,
                            color: AppColors.deepPink,
                            height: 1.1,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        AppText(
                          AppStrings.selectLanguageSubtitle,
                          fontSize: 16,
                          color: Colors.black.withOpacity(0.4),
                          fontWeight: FontWeight.w400,
                        ),
                        
                        const SizedBox(height: 40),

                        // Language Grid
                        GetBuilder<LocalizationController>(
                          builder: (localizationController) {
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.45,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 25,
                              ),
                              itemCount: localizationController.languages.length,
                              itemBuilder: (context, index) {
                                final language = localizationController.languages[index];
                                final isSelected = localizationController.selectedIndex == index;
                                return _buildLanguageCard(language, isSelected, localizationController);
                              },
                            );
                          }
                        ),
                        
                        const SizedBox(height: 120), // Space for bottom button
                      ],
                    ),
                  ),
                ),
                
                // Bottom Button
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: CustomButton(
                    text: AppStrings.next,
                    onTap: () => Get.toNamed(RouteHelper.getNameSetupRoute()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(LanguageModel language, bool isSelected, LocalizationController controller) {
    final String firstChar = language.languageName.isNotEmpty ? language.languageName[0] : "";
    
    return GestureDetector(
      onTap: () => controller.setLanguage(language),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Card
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.deepPink : Colors.black.withOpacity(0.06),
                width: isSelected ? 2.5 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected 
                      ? AppColors.deepPink.withOpacity(0.12)
                      : Colors.black.withOpacity(0.02),
                  blurRadius: isSelected ? 15 : 5,
                  offset: isSelected ? const Offset(0, 8) : const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Minimal selection indicator
                if (isSelected)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.deepPink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                
                // Language Name
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        language.languageName,
                        fontSize: 18,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? const Color(0xFF2D2D2D) : Colors.black54,
                        letterSpacing: 0.2,
                      ),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          height: 2.5,
                          width: 25,
                          decoration: BoxDecoration(
                            color: AppColors.deepPink,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          //
          // // Overlapping Character (Now on Top)
          // Positioned(
          //   bottom: -15,
          //   right: -10,
          //   child: IgnorePointer(
          //     child: Opacity(
          //       opacity: isSelected ? 0.35 : 0.15,
          //       child: Text(
          //         firstChar,
          //         style: GoogleFonts.playfairDisplay(
          //           fontSize: 100,
          //           fontWeight: FontWeight.w900,
          //           color: isSelected ? AppColors.primaryColor : Colors.grey,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPattern(BuildContext context) {
    return Positioned(
      top: -100,
      right: -100,
      child: Opacity(
        opacity: 0.05,
        child: Icon(
          Icons.language,
          size: 400,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}
