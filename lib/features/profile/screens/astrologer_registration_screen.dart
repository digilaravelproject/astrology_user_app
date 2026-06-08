import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/utils/custom_snackbar.dart';

class AstrologerRegistrationScreen extends StatelessWidget {
  const AstrologerRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.astrologerRegistration,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.lightPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Iconsax.user_add_copy, size: 48, color: AppColors.deepPink),
                  const SizedBox(height: 16),
                  AppText(
                    "Join our Team of Experts",
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    "Share your wisdom and help people find their path.",
                    fontSize: 14,
                    color: Colors.black54,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
             const SizedBox(height: 30),
            _buildTextField("Full Name", Iconsax.user_copy),
            const SizedBox(height: 16),
            _buildTextField("Email Address", Iconsax.sms_copy),
            const SizedBox(height: 16),
            _buildTextField("Mobile Number", Iconsax.call_copy),
            const SizedBox(height: 16),
            _buildTextField("Specialization (e.g. Vedic, Tarot)", Iconsax.magic_star_copy),
            const SizedBox(height: 16),
            _buildTextField("Experience (Years)", Iconsax.timer_1_copy),
            
            const SizedBox(height: 40),
            CustomButton(
              text: "Submit Application",
              onTap: () {
                 Get.back();
                 CustomSnackbar.showSuccess("Application Submitted Successfully");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]!),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(12),
             border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
