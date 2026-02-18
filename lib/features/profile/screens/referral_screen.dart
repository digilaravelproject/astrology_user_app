import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.referAndEarn,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.network(
              "https://img.freepik.com/free-vector/refer-friend-concept-illustration_114360-7039.jpg?t=st=1716960000~exp=1716963600~hmac=6069e80...",
              height: 200,
              errorBuilder: (context, error, stackTrace) => Icon(Iconsax.gift_copy, size: 100, color: AppColors.lightPink),
            ),
            const SizedBox(height: 30),
            AppText(
              "Refer a Friend & Earn ₹100",
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            AppText(
              "Share your referral code with your friends and get ₹100 in your wallet when they sign up.",
              fontSize: 14,
              color: Colors.grey,
              textAlign: TextAlign.center,
              height: 1.5,
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        "Your Referral Code",
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        "ASTRO2024",
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepPink,
                        letterSpacing: 1.5,
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: "ASTRO2024"));
                      Get.snackbar("Copied", "Referral code copied to clipboard", 
                        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(20),
                        backgroundColor: Colors.black87, colorText: Colors.white,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4),
                        ],
                      ),
                      child: const Icon(Icons.copy_rounded, color: AppColors.deepPink, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: "Share Now",
              onTap: () {
                // Share logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
