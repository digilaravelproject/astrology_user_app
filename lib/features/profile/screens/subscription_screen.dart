import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.manageSubscription,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCurrentPlan(),
            const SizedBox(height: 30),
            AppText(
              "Available Plans",
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
             const SizedBox(height: 16),
            _buildPlanCard(
              title: "Silver Plan",
              price: "₹499/mo",
              features: ["Daily Horoscope", "1 Free Call/mo", "Basic Reports"],
              color: Colors.blueGrey,
            ),
             const SizedBox(height: 16),
             _buildPlanCard(
              title: "Gold Plan",
              price: "₹999/mo",
              features: ["Detailed Horoscope", "3 Free Calls/mo", "Advanced Reports", "Priority Support"],
              color: Colors.amber,
              isPopular: true,
            ),
             const SizedBox(height: 16),
             _buildPlanCard(
              title: "Platinum Plan",
              price: "₹1999/mo",
              features: ["Unlimited Horoscope", "Unlimited Calls", "Detailed Life Report", "24/7 Priority Support"],
              color: const Color(0xFF2E1A47),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlan() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [AppColors.deepPink, AppColors.deepPink.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    "Current Plan",
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    "Free Tier",
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.flash_copy, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              AppText(
                "Basic Daily Horoscope",
                fontSize: 14,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required List<String> features,
    required Color color,
    bool isPopular = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPopular ? AppColors.deepPink : Colors.grey.shade200, width: isPopular ? 2 : 1),
        boxShadow: [
          if (isPopular)
          BoxShadow(
            color: AppColors.deepPink.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isPopular)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.deepPink,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: AppText(
                  "POPULAR",
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          AppText(
            title,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
          const SizedBox(height: 4),
          AppText(
            price,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
          const SizedBox(height: 20),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_rounded, size: 18, color: Colors.green),
                const SizedBox(width: 8),
                AppText(feature, fontSize: 14, color: Colors.grey.shade700),
              ],
            ),
          )),
          const SizedBox(height: 20),
          CustomButton(
            text: "Upgrade",
            onTap: () {},
            backgroundColor: isPopular ? AppColors.deepPink : Colors.grey.shade200,
            textColor: isPopular ? Colors.white : Colors.black87,
          ),
        ],
      ),
    );
  }
}
