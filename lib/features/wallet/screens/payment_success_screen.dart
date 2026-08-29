import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../routes/route_helper.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments = Get.arguments ?? {};
    final String amount = arguments['amount']?.toString() ?? '0.00';
    final String orderId = arguments['orderId']?.toString() ?? 'N/A';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success Icon/Animation Placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Iconsax.tick_circle,
                    color: AppColors.primaryColor,
                    size: 80,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const AppText(
                'Payment Successful',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2E1A47),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.4,
                    fontFamily: 'Poppins',
                  ),
                  children: [
                    TextSpan(
                      text: '₹$amount ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'has been successfully added to your wallet.'.tr,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // Transaction Details Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Amount Paid', '₹$amount'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                    ),
                    _buildDetailRow('Order ID', orderId),
                  ],
                ),
              ),

              const Spacer(),

              CustomButton(
                text: 'Back to Dashboard',
                fontSize: 16,
                height: 56,
                borderRadius: 16,
                onTap: () => Get.offAllNamed(RouteHelper.getDashboardRoute()),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          fontSize: 14,
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: AppText(
              value,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E1A47),
              textAlign: TextAlign.end,
            ),
          ),
        ),
      ],
    );
  }
}
