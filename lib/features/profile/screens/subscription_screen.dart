import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../routes/app_routes.dart';
import '../controllers/profile_controller.dart';
import '../domain/models/plan_model.dart';
import 'subscription_details_screen.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    
    // Fetch plans when screen is accessed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchPlans();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.manageSubscription,
        centerTitle: true,
      ),
      body: Obx(() {
        if (profileController.isLoading.value && profileController.plans.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildCurrentPlan(profileController.activePlan),
              const SizedBox(height: 16),
              AppText(
                "Available Plans",
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              const SizedBox(height: 16),
              ...List.generate(profileController.plans.length, (index) {
                final plan = profileController.plans[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPlanCard(plan),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentPlan(PlanModel? activePlan) {
    final planName = activePlan?.name ?? 'You haven’t purchased any plan.';
    final planPrice = activePlan != null ? '₹${activePlan.price}/mo' : 'Free';

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
                    "Subscribed Plan",
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    planName,
                    fontSize: 16,
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
          if (activePlan != null) ...[
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText(
                    activePlan.description,
                    fontSize: 12,
                    color: Colors.white,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText(
                    "Basic Daily Horoscope",
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanCard(PlanModel plan) {
    //final color = _getPlanColor(plan.name);
    final bool isPurchased = plan.purchased.toString() == 'true';

    return Opacity(
      opacity: isPurchased ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: isPurchased ? null : (){
          Get.to(() => SubscriptionDetailScreen(planId: plan.id));
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
           border: Border.all(color: AppColors.deepPink, width: 1),
           // border: Border.all(color: isPopular ? AppColors.deepPink : Colors.grey.shade200, width: isPopular ? 2 : 1),
            boxShadow: [
              //if (isPopular)
                BoxShadow(
                  color: AppColors.deepPink.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // if (isPopular)
              //   Align(
              //     alignment: Alignment.topRight,
              //     child: Container(
              //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //       decoration: BoxDecoration(
              //         color: AppColors.deepPink,
              //         borderRadius: BorderRadius.circular(4),
              //       ),
              //       child: AppText(
              //         "POPULAR",
              //         fontSize: 10,
              //         fontWeight: FontWeight.w700,
              //         color: Colors.white,
              //       ),
              //     ),
              //   ),
              AppText(
                plan.name,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
              const SizedBox(height: 4),
              AppText(
                '₹${plan.price}',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
              const SizedBox(height: 8),
              AppText(
                '${plan.durationDays} days',
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              const SizedBox(height: 10),
              AppText(
                plan.description,
                fontSize: 14,
                color: Colors.grey.shade700,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (isPurchased)
                AppText(
                  'Already Purchased',
                  fontSize: 12,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPlanColor(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('basic')) return Colors.blueGrey;
    if (lowerName.contains('standard')) return Colors.amber;
    if (lowerName.contains('premium')) return const Color(0xFF2E1A47);
    return Colors.blueGrey;
  }
}
