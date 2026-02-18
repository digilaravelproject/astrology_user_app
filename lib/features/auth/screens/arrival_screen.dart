import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/app_routes.dart';
import '../../../routes/route_helper.dart';
import '../../../core/constants/app_strings.dart';

import '../../../core/theme/app_colors.dart';

class ArrivalScreen extends StatelessWidget {
  const ArrivalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               // Large Success Icon with Glow
              _buildSuccessIcon(),
              
              const SizedBox(height: 40),
              
              Text(
                AppStrings.welcome,
                style: GoogleFonts.poppins(
                  fontSize: 42,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                AppStrings.registrationSuccessful,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: AppColors.black.withOpacity(0.4),
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              const SizedBox(height: 80),

              // Premium Gradient Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GestureDetector(
                  onTap: () => Get.offNamed(RouteHelper.getLanguageSelectionRoute()),
                  child: Container(
                    width: double.infinity,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        AppStrings.getStarted,
                        style: GoogleFonts.poppins(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.1), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 100,
            color: AppColors.primaryColor,
          ),
          // Subtle outer glow
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

// Minimal stub for AppRoutes inside this file or use full Import if needed
// For now I'll use the RouteHelper directly in next steps
