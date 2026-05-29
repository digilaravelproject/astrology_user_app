import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/call/screens/call_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text.dart';
import '../../core/widgets/custom_button.dart';
import '../../features/wallet/screens/wallet_screen.dart';
import '../../features/wallet/widgets/recharge_bottom_sheet.dart';
import '../services/network/api_client.dart';
import '../../core/constants/app_urls.dart';
import '../../core/utils/custom_snackbar.dart';

class WalletHelper {
  static void checkBalanceAndProceed({
    required BuildContext context,
    required String type,
    required String name,
    required String imageUrl,
    required String price,
    required int providerId,
    double? simulatedBalance,
  }) {
    // Simulated wallet balance
    final double walletBalance = simulatedBalance ?? 10.0; // Default to low balance if not provided
    final double requiredAmount = double.tryParse(price) ?? 0.0;
    final bool hasSufficientBalance = walletBalance >= requiredAmount;

    if (!hasSufficientBalance) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => RechargeBottomSheet(
          neededAmount: requiredAmount,
          serviceType: type,
        ),
      );
      return;
    }

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
              
              const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 32),
              const SizedBox(height: 8),
              AppText(
                "Ready to Connect",
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              const SizedBox(height: 8),
              AppText(
                "You have sufficient balance to start the $type.",
                fontSize: 14,
                color: Colors.grey.shade600,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Start ${type.capitalizeFirst}",
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  onTap: () async {
                    if (type == 'chat') {
                      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                      try {
                        final apiClient = Get.find<ApiClient>();
                        final response = await apiClient.post(
                          AppUrls.initiateChat,
                          data: {'provider_id': providerId},
                        );
                        Get.back(); // close loader
                        if (response.isSuccess) {
                          Get.back(); // close bottom sheet
                          CustomSnackbar.showSuccess(response.message);
                          Get.to(() => ChatScreen(astrologerName: name, astrologerImage: imageUrl));
                        } else {
                          CustomSnackbar.showError(response.message);
                        }
                      } catch (e) {
                        Get.back(); // close loader
                        CustomSnackbar.showError(e.toString());
                      }
                    } else {
                      Get.back();
                      Get.to(() => CallScreen(astrologerName: name, astrologerImage: imageUrl));
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
