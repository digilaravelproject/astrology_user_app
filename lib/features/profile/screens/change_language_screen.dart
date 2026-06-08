import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../language/controllers/localization_controller.dart';
import '../../language/domain/models/language_model.dart';

class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({super.key});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  final LocalizationController _localizationController = Get.find<LocalizationController>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _localizationController.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final languages = _localizationController.languages;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.changeLanguage,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: languages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final lang = languages[index];
                final isSelected = _selectedIndex == index;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.lightPink.withOpacity(0.2) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.deepPink : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: isSelected ? AppColors.deepPink : Colors.grey.shade100,
                          child: AppText(
                            lang.languageName.substring(0, 1),
                            fontSize: 16,
                            color: isSelected ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              lang.languageName,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            AppText(
                              '${lang.languageCode.toUpperCase()}_${lang.countryCode}',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: AppColors.deepPink, size: 24)
                        else
                          Icon(Icons.radio_button_off_rounded, color: Colors.grey.shade300, size: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: CustomButton(
              text: AppStrings.saveChanges,
              onTap: () {
                // Use LocalizationController to change language
                _localizationController.setLanguage(languages[_selectedIndex]);
                
                // Show success message
                CustomSnackbar.showSuccess("Language changed to ${languages[_selectedIndex].languageName}");
                
                // Go back to profile screen
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}
