import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../astrologers/screens/astrologer_detail_screen.dart';
import '../../astrologers/bindings/astrologers_binding.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_image_widget.dart';
import '../../../core/constants/app_urls.dart';
import '../../notification/controllers/notification_controller.dart';
import '../../../core/utils/wallet_helper.dart';
import '../../astrologers/controllers/astrologer_controller.dart';
import '../../astrologers/domain/models/astrologer_model.dart';
import '../../../core/widgets/custom_rating_bar.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../../../core/utils/session_bottom_sheet_helper.dart';

class AstrologersPreviewSection extends StatelessWidget {
  const AstrologersPreviewSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AstrologerController>();

    return Obx(() {
      if (controller.isLoading.value && controller.astrologers.isEmpty) {
        return _buildShimmerList();
      }

      if (controller.astrologers.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(
                  Icons.person_search_rounded,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                AppText(
                  'No Astrologers Found',
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...controller.astrologers
              .map((astro) => _buildAstrologerCard(context, astro))
              .toList(),
        ],
      );
    });
  }

  Widget _buildAstrologerCard(BuildContext context, AstrologerModel astro) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => AstrologerDetailScreen(astrologerId: astro.id),
          binding: AstrologersBinding(),
          arguments: astro.id,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Profile Image
                Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      padding: const EdgeInsets.all(
                        4,
                      ), // Space between gold and image
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.goldAccent,
                          width: 2,
                        ),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child:
                            astro.profilePhoto != null &&
                                    astro.profilePhoto!.isNotEmpty
                                ? CustomImageWidget(
                                  imagePath: astro.fullProfilePhoto,
                                  fit: BoxFit.cover,
                                )
                                : _buildPlaceholderLarge(),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: astro.isAvailableOnline ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Rating and Orders Placeholder
                CustomRatingBar(rating: astro.rating, size: 15),
                const SizedBox(width: 12),
                AppText(
                  '${astro.totalOrders > 0 ? astro.totalOrders : (astro.id * 15 + 100)}k+ ${AppStrings.ordersLabel}',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name
                            Row(
                              children: [
                                Flexible(
                                  child: AppText(
                                    astro.name,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, color: Colors.green, size: 16),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // Skills
                            AppText(
                              astro.areasOfExpertise.join(', '),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Languages
                            AppText(
                              astro.languages.join(', '),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Experience
                            AppText(
                              '${AppStrings.expLabelPrefix} ${astro.yearsOfExperience} ${AppStrings.years}',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                  /*
                  if (astro.hasOffer)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: AppText(
                          '${astro.discountPercentage ?? ''}% OFF',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  SizedBox(height: astro.hasOffer ? 8 : 12),
                  */
                  const SizedBox(height: 12),

                  // Buttons Row
                  Align(
                    alignment: Alignment.centerRight,
                    child: (astro.isAvailableOnline)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CustomButton(
                                text: astro.packageSessionText,
                                icon: Icons.timer,
                                fontSize: 10,
                                height: 32,
                                width: (astro.isChatEnabled && astro.isCallEnabled) ? 198 : 180,
                                borderRadius: 8,
                                backgroundColor: astro.isPurchase == true ? Colors.green : Colors.orange,
                                textColor: Colors.white,
                                borderColor: astro.isPurchase == true ? Colors.green : Colors.orange,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                onTap: () {
                                  SessionBottomSheetHelper.show(context, astro);
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (astro.isChatEnabled)
                                    CustomButton(
                                      text: '${AppStrings.chat} ₹${double.tryParse(astro.chatRate ?? '0')?.toStringAsFixed(0) ?? '0'}',
                                      icon: Icons.chat_bubble_outline_rounded,
                                      fontSize: 10,
                                      height: 32,
                                      width: 95,
                                      borderRadius: 8,
                                      backgroundColor: Colors.transparent,
                                      textColor: const Color(0xFF4CAF50),
                                      borderColor: const Color(0xFF4CAF50),
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      onTap: () {
                                        final walletController = Get.find<WalletController>();
                                        final double balance = double.tryParse(walletController.balance) ?? 0.0;
                                        WalletHelper.checkBalanceAndProceed(
                                          context: context,
                                          type: 'chat',
                                          name: astro.name,
                                          imageUrl: astro.fullProfilePhoto,
                                          price: astro.chatRate ?? '0',
                                          providerId: astro.userId,
                                          simulatedBalance: balance,
                                        );
                                      },
                                    ),
                                  if (astro.isChatEnabled && astro.isCallEnabled)
                                    const SizedBox(width: 8),
                                  if (astro.isCallEnabled)
                                    CustomButton(
                                      text: '${AppStrings.call} ₹${double.tryParse(astro.callRate ?? '0')?.toStringAsFixed(0) ?? '0'}',
                                      icon: Icons.call_outlined,
                                      fontSize: 10,
                                      height: 32,
                                      width: 95,
                                      borderRadius: 8,
                                      backgroundColor: Colors.transparent,
                                      textColor: const Color(0xFF4CAF50),
                                      borderColor: const Color(0xFF4CAF50),
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      onTap: () {
                                        final walletController = Get.find<WalletController>();
                                        final double balance = double.tryParse(walletController.balance) ?? 0.0;
                                        WalletHelper.checkBalanceAndProceed(
                                          context: context,
                                          type: 'call',
                                          name: astro.name,
                                          imageUrl: astro.fullProfilePhoto,
                                          price: astro.callRate ?? '0',
                                          providerId: astro.userId,
                                          simulatedBalance: balance,
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ],
                          )
                        : const Text(
                            "Astrologer is offline.",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.lightPink,
      child: const Icon(Icons.person, color: AppColors.primaryColor, size: 36),
    );
  }

  Widget _buildPlaceholderLarge() {
    return Container(
      color: AppColors.lightPink,
      child: const Icon(Icons.person, color: AppColors.primaryColor, size: 50),
    );
  }



  Widget _buildShimmerList() {
    return Column(
      children: List.generate(
        3,
        (index) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
        ),
      ),
    );
  }
}
