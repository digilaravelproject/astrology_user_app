import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../astrologers/domain/models/astrologer_model.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../../../core/utils/wallet_helper.dart';

class AstrologerActionButtons extends StatelessWidget {
  final AstrologerModel astro;
  final bool isDetailStyle;
  final bool showChat;
  final bool showCall;
  final int? providerIdFallback;

  const AstrologerActionButtons({
    Key? key,
    required this.astro,
    this.isDetailStyle = false,
    this.showChat = true,
    this.showCall = true,
    this.providerIdFallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasChat = showChat && (astro.isChatEnabled == true);
    final bool hasCall = showCall && (astro.isCallEnabled == true);
    final bool isActuallyOffline = !(astro.isOnline) || (!hasChat && !hasCall);

    if (isActuallyOffline) {
      if (isDetailStyle) {
        return Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Currently Offline'.tr,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      } else {
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  CustomSnackbar.showInfo('Astrologer is currently offline.');
                },
                child: Container(
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF94A3B8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Offline'.tr,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }
    }

    if (isDetailStyle) {
      return Row(
        children: [
          if (hasChat)
            Expanded(
              child: GestureDetector(
                onTap: astro.isBlocked == true 
                  ? () => CustomSnackbar.showError("This astrologer is blocked") 
                  : (astro.isBusy == true)
                      ? () => CustomSnackbar.showInfo('Astrologer is currently engaged.')
                      : () {
                          final walletController = Get.find<WalletController>();
                          final double balance = double.tryParse(walletController.balance) ?? 0.0;
                          WalletHelper.checkBalanceAndProceed(
                            context: context,
                            type: 'chat',
                            name: astro.name,
                            imageUrl: astro.fullProfilePhoto,
                            price: astro.chatRate ?? '0',
                            providerId: astro.userId > 0 ? astro.userId : (providerIdFallback ?? 0),
                            simulatedBalance: balance,
                          );
                        },
                child: Opacity(
                  opacity: astro.isBlocked == true ? 0.6 : 1.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: (astro.isBlocked == true || astro.isBusy == true)
                          ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade600])
                          : const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF388E3C)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: ((astro.isBlocked == true || astro.isBusy == true) ? Colors.grey : const Color(0xFF4CAF50)).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.message_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text((astro.isBlocked == true ? 'Blocked' : (astro.isBusy == true ? 'Busy' : 'Chat')).tr, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                                if (astro.hasOffer == true)
                                  Container(
                                    margin: const EdgeInsets.only(left: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.yellow.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      '${astro.discountPercentage ?? ''}% OFF',
                                      style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w800, color: Colors.yellow),
                                    ),
                                  ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (astro.hasOffer == true && astro.originalChatRatePerMinute != null)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Text(
                                      '₹ ${double.tryParse(astro.originalChatRatePerMinute!)?.toStringAsFixed(2) ?? astro.originalChatRatePerMinute!}',
                                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9), decoration: TextDecoration.lineThrough,decorationColor: Colors.white,),
                                    ),
                                  ),
                                Text('₹ ${double.tryParse(astro.chatRate ?? '0')?.toStringAsFixed(2) ?? astro.chatRate ?? '0'}${"/min".tr}', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9))),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (hasChat && hasCall) const SizedBox(width: 10),
          if (hasCall)
            Expanded(
              child: GestureDetector(
                onTap: astro.isBlocked == true 
                  ? () => CustomSnackbar.showError("This astrologer is blocked") 
                  : (astro.isBusy == true)
                      ? () => CustomSnackbar.showInfo('Astrologer is currently engaged.')
                      : () {
                          final walletController = Get.find<WalletController>();
                          final double balance = double.tryParse(walletController.balance) ?? 0.0;
                          WalletHelper.checkBalanceAndProceed(
                            context: context,
                            type: 'call',
                            name: astro.name,
                            imageUrl: astro.fullProfilePhoto,
                            price: astro.callRate ?? '0',
                            providerId: astro.userId > 0 ? astro.userId : (providerIdFallback ?? 0),
                            simulatedBalance: balance,
                          );
                        },
                child: Opacity(
                  opacity: astro.isBlocked == true ? 0.6 : 1.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: (astro.isBlocked == true || astro.isBusy == true)
                          ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade600])
                          : const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: ((astro.isBlocked == true || astro.isBusy == true) ? Colors.grey : const Color(0xFFD32F2F)).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.call, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text((astro.isBlocked == true ? 'Blocked' : (astro.isBusy == true ? 'Busy' : 'Call')).tr, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                                if (astro.hasOffer == true)
                                  Container(
                                    margin: const EdgeInsets.only(left: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.yellow.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      '${astro.discountPercentage ?? ''}% OFF',
                                      style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w800, color: Colors.yellow),
                                    ),
                                  ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (astro.hasOffer == true && astro.originalCallRatePerMinute != null)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Text(
                                      '₹ ${double.tryParse(astro.originalCallRatePerMinute!)?.toStringAsFixed(2) ?? astro.originalCallRatePerMinute!}',
                                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9),
                                          decoration: TextDecoration.lineThrough,
                                        decorationColor: Colors.white,
                                        ),
                                    ),
                                  ),
                                Text('₹ ${double.tryParse(astro.callRate ?? '0')?.toStringAsFixed(2) ?? astro.callRate ?? '0'}/min', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9))),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    } else {
      return Row(
        children: [
          if (hasChat)
            Expanded(
              child: CustomButton(
                text: astro.isBusy
                    ? 'Busy'
                    : '${AppStrings.chat.tr} - ₹${double.tryParse(astro.chatRate ?? '0')?.toStringAsFixed(2) ?? astro.chatRate ?? '0'}/min',
                icon: Icons.chat_bubble_outline_rounded,
                fontSize: 10,
                height: 32,
                borderRadius: 8,
                backgroundColor:
                    (astro.isBusy)
                        ? Colors.grey.withOpacity(0.2)
                        : Colors.transparent,
                textColor:
                    (astro.isBusy)
                        ? Colors.grey
                        : const Color(0xFF4CAF50),
                borderColor:
                    (astro.isBusy)
                        ? Colors.grey
                        : const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                onTap: () {
                  if (astro.isBusy) {
                    CustomSnackbar.showInfo('Astrologer is currently engaged.');
                    return;
                  }
                  final walletController = Get.find<WalletController>();
                  final double balance = double.tryParse(walletController.balance) ?? 0.0;
                  WalletHelper.checkBalanceAndProceed(
                    context: context,
                    type: 'chat',
                    name: astro.name,
                    imageUrl: astro.fullProfilePhoto,
                    price: astro.chatRate ?? '0',
                    providerId: astro.userId > 0 ? astro.userId : (providerIdFallback ?? 0),
                    simulatedBalance: balance,
                  );
                },
              ),
            ),
          if (hasChat && hasCall) const SizedBox(width: 8),
          if (hasCall)
            Expanded(
              child: CustomButton(
                text: astro.isBusy
                    ? 'Busy'
                    : '${AppStrings.call.tr} - ₹${double.tryParse(astro.callRate ?? '0')?.toStringAsFixed(2) ?? astro.callRate ?? '0'}/min',
                icon: Icons.call_outlined,
                fontSize: 10,
                height: 32,
                borderRadius: 8,
                backgroundColor:
                    (astro.isBusy)
                        ? Colors.grey.withOpacity(0.2)
                        : Colors.transparent,
                textColor:
                    (astro.isBusy)
                        ? Colors.grey
                        : const Color(0xFF4CAF50),
                borderColor:
                    (astro.isBusy)
                        ? Colors.grey
                        : const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                onTap: () {
                  if (astro.isBusy) {
                    CustomSnackbar.showInfo('Astrologer is currently engaged.');
                    return;
                  }
                  final walletController = Get.find<WalletController>();
                  final double balance = double.tryParse(walletController.balance) ?? 0.0;
                  WalletHelper.checkBalanceAndProceed(
                    context: context,
                    type: 'call',
                    name: astro.name,
                    imageUrl: astro.fullProfilePhoto,
                    price: astro.callRate ?? '0',
                    providerId: astro.userId > 0 ? astro.userId : (providerIdFallback ?? 0),
                    simulatedBalance: balance,
                  );
                },
              ),
            ),
        ],
      );
    }
  }
}
