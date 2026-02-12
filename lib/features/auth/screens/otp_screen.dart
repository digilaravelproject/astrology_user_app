import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/image_constants.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_image_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../controllers/auth_controller.dart';
import '../../../core/constants/app_strings.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Subtle Cosmic Background
          _buildBackgroundWatermarks(),

          // 2. Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   SizedBox(height: size.height * 0.05),

                  // Header Section
                  Text(
                    AppStrings.verification,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D2D2D), // Warm charcoal
                      fontFamily: 'Playfair Display',
                      letterSpacing: -0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '${AppStrings.enterOtpSent}\n+91 ${authController.currentMobile.value}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.06),

                  // OTP Input Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      4,
                      (index) => Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF8F00).withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF8F00), // Bhagwa
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(1),
                          ],
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Color(0xFFFF8F00), width: 1.5),
                            ),
                            counterText: "",
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              if (index < 3) FocusScope.of(context).nextFocus();
                              
                              String currentOtp = authController.otpController.text;
                              if (currentOtp.length <= index) {
                                authController.otpController.text = currentOtp + value;
                              } else {
                                List<String> chars = currentOtp.split('');
                                chars[index] = value;
                                authController.otpController.text = chars.join('');
                              }
                            } else {
                              if (index > 0) FocusScope.of(context).previousFocus();
                              String currentOtp = authController.otpController.text;
                              if (currentOtp.length > index) {
                                List<String> chars = currentOtp.split('');
                                chars.removeAt(index);
                                authController.otpController.text = chars.join('');
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.08),

                  // Verify Button (Pill shaped, Gradient)
                  Obx(() => authController.isLoading.value 
                    ? const LoadingWidget()
                    : GestureDetector(
                        onTap: authController.verifyOtp,
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF8F00), // Bhagwa
                                Color(0xFFFF6D00), // Bhagwa
                                Color(0xFFD32F2F), // Red (30%)
                              ],
                              stops: [0.0, 0.6, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(27),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF8F00).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                               AppStrings.verify,
                               style: const TextStyle(
                                 color: Colors.white,
                                 fontSize: 18,
                                 fontWeight: FontWeight.w600,
                               ),
                            ),
                          ),
                        ),
                      ),
                  ),

                  const SizedBox(height: 35),

                  // Resend Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.didntReceiveCode,
                        style: TextStyle(color: Colors.black45, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => authController.login(),
                        child: Text(
                          AppStrings.resend,
                          style: const TextStyle(
                            color: Color(0xFFFF6D00),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundWatermarks() {
    return Stack(
      children: [
        _watermarkText("♈", 60, 20, size: 45, rotation: 0.2),
        _watermarkText("☀️", 120, -10, size: 70, rotation: 0),
        _watermarkText("🌙", 80, 280, size: 50, rotation: -0.4),
        _watermarkText("✨", 180, 320, size: 22, rotation: 0.1),
        _watermarkText("♉", 380, -20, size: 65, rotation: -0.1),
        _watermarkText("✨", 450, 40, size: 18, rotation: 0.5),
        _watermarkText("♊", 350, 300, size: 55, rotation: 0.5),
        _watermarkText("🪐", 520, 280, size: 75, rotation: 0.2),
        _watermarkText("♋", 650, 30, size: 60, rotation: -0.2),
      ],
    );
  }

  Widget _watermarkText(String symbol, double top, double left, {double size = 60, double rotation = 0}) {
    return Positioned(
      top: top,
      left: left,
      child: Transform.rotate(
        angle: rotation,
        child: Opacity(
          opacity: 0.045,
          child: Text(
            symbol,
            style: TextStyle(
              fontSize: size,
              color: const Color(0xFFFF8F00),
            ),
          ),
        ),
      ),
    );
  }
}
