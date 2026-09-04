import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'app_text.dart';
import 'custom_button.dart';

class PaymentSuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? orderId;
  final String? amount;
  final VoidCallback? onOk;

  const PaymentSuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.orderId,
    this.amount,
    this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.tick_circle,
                color: AppColors.primaryColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            AppText(
              title,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2E1A47),
            ),
            const SizedBox(height: 12),
            AppText(
              message,
              fontSize: 15,
              color: Colors.grey.shade600,
              textAlign: TextAlign.center,
            ),
            if (orderId != null || amount != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (amount != null) ...[
                      _buildDetailRow('Amount', '₹$amount'),
                      const SizedBox(height: 8),
                    ],
                    if (orderId != null) ...[
                      _buildDetailRow('Order ID', orderId!),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            CustomButton(
              text: 'OK'.tr,
              fontSize: 16,
              height: 50,
              borderRadius: 12,
              onTap: onOk ?? () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          fontSize: 13,
          color: Colors.grey.shade500,
        ),
        AppText(
          value,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2E1A47),
        ),
      ],
    );
  }
}
