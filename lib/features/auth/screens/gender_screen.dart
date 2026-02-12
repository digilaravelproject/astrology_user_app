import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/route_helper.dart';
import '../../../routes/app_routes.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/selection_card.dart';
import '../../../core/constants/app_strings.dart';

class GenderSetupScreen extends StatefulWidget {
  const GenderSetupScreen({Key? key}) : super(key: key);

  @override
  State<GenderSetupScreen> createState() => _GenderSetupScreenState();
}

class _GenderSetupScreenState extends State<GenderSetupScreen> {
  String selectedGender = 'Male';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Cosmic Background Pattern
          _buildBackgroundPattern(context),

          // 2. Main Content
          SafeArea(
            child: SingleChildScrollView(
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF9933).withOpacity(0.05),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF2E1A47)),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  Text(
                    AppStrings.genderTitle,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2E1A47),
                      height: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    AppStrings.genderSubtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 50),

                  // Premium Gender Cards
                  Row(
                    children: [
                      Expanded(
                        child: SelectionCard(
                          label: AppStrings.male,
                          icon: Icons.male_rounded,
                          isSelected: selectedGender == 'Male',
                          onTap: () => setState(() => selectedGender = 'Male'),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: SelectionCard(
                          label: AppStrings.female,
                          icon: Icons.female_rounded,
                          isSelected: selectedGender == 'Female',
                          onTap: () => setState(() => selectedGender = 'Female'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 80),

                  // Premium Gradient Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: GradientButton(
                      text: AppStrings.next,
                      onTap: () => Get.toNamed(AppRoutes.birthDetails),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildBackgroundPattern(BuildContext context) {
    final iconColor = const Color(0xFFFF9933).withOpacity(0.06);

    return Stack(
      children: [
        Positioned(top: 100, left: 40, child: Icon(Icons.brightness_5_outlined, size: 35, color: iconColor)),
        Positioned(top: 250, right: 60, child: Icon(Icons.nightlight_round_outlined, size: 28, color: iconColor)),
        Positioned(top: 500, left: 80, child: Icon(Icons.auto_awesome_outlined, size: 32, color: iconColor)),
        Positioned(bottom: 200, right: 40, child: Icon(Icons.star_border_rounded, size: 40, color: iconColor)),
        Positioned(bottom: 350, left: 30, child: Icon(Icons.wb_twilight_rounded, size: 24, color: iconColor)),
        Positioned(top: 150, right: 120, child: Icon(Icons.flare_rounded, size: 20, color: iconColor)),
        Positioned(bottom: 100, left: 150, child: Icon(Icons.blur_on_rounded, size: 45, color: iconColor)),
      ],
    );
  }
}
