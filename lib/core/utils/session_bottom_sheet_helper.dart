import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/astrologers/domain/models/astrologer_model.dart';
import '../../features/wallet/controllers/wallet_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/app_text.dart';
import '../widgets/custom_button.dart';
import '../constants/app_strings.dart';

class SessionBottomSheetHelper {
  static void show(BuildContext context, AstrologerModel astro) {
    final walletController = Get.find<WalletController>();
    final double walletBalance = double.tryParse(walletController.balance) ?? 0.0;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Balance Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.deepPink.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          "Wallet Balance",
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          "₹${walletBalance.toStringAsFixed(2)}",
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepPink,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_wallet, color: AppColors.deepPink),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (astro.isChatEnabled)
                    CustomButton(
                      text: '${AppStrings.chat} ₹${double.tryParse(astro.chatRate ?? '0')?.toStringAsFixed(0) ?? '0'}',
                      icon: Icons.chat_bubble_outline_rounded,
                      fontSize: 12,
                      height: 45,
                      width: 140,
                      borderRadius: 12,
                      onTap: () {
                        // Do nothing for now
                      },
                    ),
                  if (astro.isCallEnabled)
                    CustomButton(
                      text: '${AppStrings.call} ₹${double.tryParse(astro.callRate ?? '0')?.toStringAsFixed(0) ?? '0'}',
                      icon: Icons.call_outlined,
                      fontSize: 12,
                      height: 45,
                      width: 140,
                      borderRadius: 12,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4CAF50),
                          Color(0xFF388E3C),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        // Do nothing for now
                      },
                    ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
