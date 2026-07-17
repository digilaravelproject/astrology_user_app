import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/astrologers/domain/models/astrologer_model.dart';
import '../../features/wallet/controllers/wallet_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/app_text.dart';
import '../widgets/custom_button.dart';
import '../constants/app_strings.dart';

import '../../features/wallet/widgets/recharge_bottom_sheet.dart';
import '../services/network/api_client.dart';
import '../constants/app_urls.dart';
import '../utils/custom_snackbar.dart';
import '../../features/astrologers/controllers/astrologer_controller.dart';

class SessionBottomSheetHelper {
  static void show(BuildContext context, AstrologerModel astro) {
    final walletController = Get.find<WalletController>();
    final double walletBalance = double.tryParse(walletController.balance) ?? 0.0;

    // If package is not purchased, verify wallet balance and show confirmation.
    if (astro.isPurchase == false) {
      final double requiredAmount = (astro.packagePrice ?? 500).toDouble();
      if (walletBalance < requiredAmount) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => RechargeBottomSheet(
            neededAmount: requiredAmount,
            serviceType: 'package',
          ),
        );
      } else {
        _showPurchaseConfirmationSheet(context, astro, walletBalance, requiredAmount);
      }
      return;
    }

    final int remainingSeconds = astro.remainingTime ?? 0;
    String remainingTimeStr;
    if (remainingSeconds < 60) {
      remainingTimeStr = '$remainingSeconds sec';
    } else if (remainingSeconds < 3600) {
      final int mins = remainingSeconds ~/ 60;
      remainingTimeStr = '$mins min';
    } else {
      final int remainingMinutes = remainingSeconds ~/ 60;
      final int remDays = remainingMinutes ~/ 1440;
      final int remHours = (remainingMinutes % 1440) ~/ 60;
      final int remMins = remainingMinutes % 60;

      if (remDays > 0) {
        if (remHours > 0) {
          remainingTimeStr = '$remDays day $remHours hr';
        } else {
          remainingTimeStr = '$remDays day';
        }
      } else {
        if (remMins > 0) {
          remainingTimeStr = '$remHours hr $remMins min';
        } else {
          remainingTimeStr = '$remHours hr';
        }
      }
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
              const SizedBox(height: 8),
              
              // Header
              AppText(
                "Connect with ${astro.name}",
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade900,
              ),
              const SizedBox(height: 6),
              AppText(
                "Select a service to start your session",
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 20),

              // Remaining Time Info
              if (astro.remainingTime != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade200, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.timer_outlined, color: Colors.orange.shade800, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              "Remaining Package Time",
                              fontSize: 11,
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                            const SizedBox(height: 2),
                            AppText(
                              remainingTimeStr,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange.shade900,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (astro.isChatEnabled)
                      Expanded(
                        child: CustomButton(
                          text: AppStrings.chat,
                          icon: Icons.chat_bubble_outline_rounded,
                          fontSize: 13,
                          height: 48,
                          borderRadius: 12,
                          onTap: null,
                        ),
                      ),
                    if (astro.isChatEnabled && astro.isCallEnabled)
                      const SizedBox(width: 12),
                    if (astro.isCallEnabled)
                      Expanded(
                        child: CustomButton(
                          text: AppStrings.call,
                          icon: Icons.call_outlined,
                          fontSize: 13,
                          height: 48,
                          borderRadius: 12,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF4CAF50),
                              Color(0xFF388E3C),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onTap: null,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  static void _showPurchaseConfirmationSheet(
    BuildContext context,
    AstrologerModel astro,
    double walletBalance,
    double requiredAmount,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        RxBool isPurchasing = false.obs;
        return Container(
          padding: const EdgeInsets.all(20),
          child: Obx(() {
            if (isPurchasing.value) {
              return const SizedBox(
                height: 180,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.deepPink),
                      SizedBox(height: 16),
                      Text("Purchasing package, please wait..."),
                    ],
                  ),
                ),
              );
            }
            return Column(
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
                const SizedBox(height: 16),
                AppText(
                  "Confirm Package Purchase",
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
                const SizedBox(height: 6),
                AppText(
                  "Would you like to purchase this session package for ₹${astro.packagePrice ?? 500}?",
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "Cancel",
                        backgroundColor: Colors.grey.shade200,
                        textColor: Colors.grey.shade800,
                        borderColor: Colors.grey.shade200,
                        borderRadius: 12,
                        height: 48,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: "Purchase",
                        borderRadius: 12,
                        height: 48,
                        onTap: () async {
                          isPurchasing.value = true;
                          try {
                            final response = await Get.find<ApiClient>().post(
                              AppUrls.purchasePackage,
                              data: {'astrologer_id': astro.userId},
                            );
                            if (response.isSuccess) {
                              CustomSnackbar.showSuccess("Package purchased successfully.");
                              Navigator.pop(context);
                              // Refresh wallet balance
                              await Get.find<WalletController>().fetchWallet();
                              final astrologerController = Get.find<AstrologerController>();
                              await astrologerController.fetchAstrologers();
                              final updatedAstro = astrologerController.astrologers.firstWhere(
                                (a) => a.id == astro.id,
                                orElse: () => astro,
                              );
                              show(context, updatedAstro);
                            } else {
                              CustomSnackbar.showError(response.message);
                              isPurchasing.value = false;
                            }
                          } catch (e) {
                            CustomSnackbar.showError("Something went wrong during purchase.");
                            isPurchasing.value = false;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            );
          }),
        );
      },
    );
  }
}
