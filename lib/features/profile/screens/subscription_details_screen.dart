import 'package:astro_user/core/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/payment_success_dialog.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../domain/models/plan_model.dart';
import '../../../core/services/payment/razorpay/razorpay_service.dart';
import '../../../core/services/payment/razorpay/razorpay_config.dart';

class SubscriptionDetailScreen extends StatelessWidget {
  final int planId;

  SubscriptionDetailScreen({super.key, required this.planId});

  final RazorpayService _razorpayService = RazorpayService();

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    // Fetch plan details when screen is accessed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchPlanById(planId);
    });

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: Obx(() {
        final plan = profileController.selectedPlan.value;

        if (plan == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button & Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 36, 20, 0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppColors.textColorPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          AppText(
                            plan.status,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Hero Section with Price - Using Pink Gradient
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                plan.name,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.schedule_outlined,
                                      color: AppColors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    AppText(
                                      '${plan.durationDays} days',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.goldAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: AppText(
                            'BEST VALUE',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepPink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppText(
                          '₹${plan.price}',
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      'Billed annually • Cancel anytime',
                      fontSize: 12,
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ],
                ),
              ),

              // Description Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'What\'s included',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    const SizedBox(height: 12),
                    AppText(
                      plan.description,
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
              ),

              // Features List
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  children: plan.features.map((feature) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepPink.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppText(
                              feature,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColorPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Info Banner - Using Pink Theme
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightPink,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              '30-Day Money-Back Guarantee',
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorPrimary,
                              fontSize: 14,
                            ),
                            AppText(
                              'Not satisfied? Get a full refund within 30 days.',
                              fontSize: 12,
                              color: AppColors.textColorSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Subscribe Button - Using Pink Theme
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                child: CustomButton(
                  text: 'Subscribe Now',
                  onTap: () => _handleSubscribe(context, profileController, plan),
                  backgroundColor: AppColors.primaryColor,
                  textColor: AppColors.white,
                  height: 56,
                  fontSize: 18,
                ),
              ),

              // Terms & Conditions
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(
                  child: AppText(
                    'By subscribing, you agree to our Terms of Service & Privacy Policy',
                    fontSize: 11,
                    color: AppColors.textColorSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _handleSubscribe(
    BuildContext context,
    ProfileController controller,
    PlanModel plan,
  ) async {
    try {
      controller.isLoading.value = true;
      final result = await controller.upgradePlan(plan.id);
      
      if (result.isSuccess && result.body != null) {
        final data = result.body as Map<String, dynamic>;

        CustomSnackbar.showSuccess(result.message);
        
        // Show success message
        Get.snackbar(
          'Success',
          data['message'] ?? 'Razorpay order created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        
        // Handle Razorpay order if present
        if (data.containsKey('razorpay_order')) {
          final razorpayOrder = data['razorpay_order'] as Map<String, dynamic>;
          final orderId = razorpayOrder['id'] as String?;
          final amount = razorpayOrder['amount'] as int?;
          final keyId = razorpayOrder['key_id'] as String?;
          
          if (orderId != null && amount != null && keyId != null) {
            _openRazorpayPayment(
              context: context,
              controller: controller,
              orderId: orderId,
              amount: amount / 100, // Convert to rupees
              keyId: keyId,
              planName: plan.name,
              plan: plan,
            );
          }
        }
      } else {
        Get.snackbar(
          'Error',
          result.message ?? 'Failed to create order',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      controller.isLoading.value = false;
    }
  }

  void _openRazorpayPayment({
    required BuildContext context,
    required ProfileController controller,
    required String orderId,
    required double amount,
    required String keyId,
    required String planName,
    required PlanModel plan,
  }) {
    // Get user email and contact from auth controller
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;
    final email = "awi@gmail.com" '';
    final contact = user?.mobile ?? '';

    _razorpayService.init(
      onSuccess: (success) {
        _verifyPayment(
          context: context,
          controller: controller,
          providerOrderId: orderId,
          providerPaymentId: success.paymentId ?? '',
          signature: success.signature ?? '',
          plan: plan,
        );
      },
      onFailure: (failure) {
        Get.snackbar(
          'Error',
          failure.message ?? 'Payment failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
      onExternalWallet: (wallet) {
        Get.snackbar(
          'Wallet',
          'Paid via ${wallet.walletName}',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );

    _razorpayService.openCheckout(
      amount: amount,
      orderId: orderId,
      name: planName,
      description: 'Plan Upgrade',
      email: email,
      contact: contact,
    );
  }

  void _verifyPayment({
    required BuildContext context,
    required ProfileController controller,
    required String providerOrderId,
    required String providerPaymentId,
    required String signature,
    PlanModel? plan,
  }) async {
    try {
      controller.isLoading.value = true;
      final result = await controller.verifyUpgrade(
        providerOrderId: providerOrderId,
        providerPaymentId: providerPaymentId,
        signature: signature,
      );

      if (result.isSuccess) {
        // Show success dialog
        Get.dialog(
          PaymentSuccessDialog(
            title: 'Subscription Successful',
            message: 'Your plan has been upgraded successfully',
            orderId: providerOrderId,
            amount: plan?.price.toString(),
            onOk: () {
              Get.back();
              Get.back();
            },
          ),
        );
      } else {
        Get.snackbar(
          'Error',
          result.message ?? 'Payment verification failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      controller.isLoading.value = false;
    }
  }
}
