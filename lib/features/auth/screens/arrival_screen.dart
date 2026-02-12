import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/app_routes.dart';
import '../../../routes/route_helper.dart';
import '../../../core/constants/app_strings.dart';

class ArrivalScreen extends StatelessWidget {
  const ArrivalScreen({Key? key}) : super(key: key);

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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   // Large Success Icon with Glow
                  _buildSuccessIcon(),
                  
                  const SizedBox(height: 40),
                  
                  Text(
                    AppStrings.welcome,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2E1A47),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    AppStrings.registrationSuccessful,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black.withOpacity(0.4),
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 80),

                  // Premium Gradient Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: GestureDetector(
                      onTap: () => Get.offNamed(AppRoutes.nameSetup),
                      child: Container(
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD32F2F), Color(0xFFFF8F00)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD32F2F).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            AppStrings.getStarted,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
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
        ],
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9933).withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFF9933).withOpacity(0.1), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 100,
            color: const Color(0xFFFF8F00),
          ),
          // Subtle outer glow
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8F00).withOpacity(0.1),
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

  Widget _buildBackgroundPattern(BuildContext context) {
    final size = MediaQuery.of(context).size;
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

// Minimal stub for AppRoutes inside this file or use full Import if needed
// For now I'll use the RouteHelper directly in next steps
