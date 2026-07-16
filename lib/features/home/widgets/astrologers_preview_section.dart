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
                      if (astro.hasOffer)
                        Padding(
                          padding: const EdgeInsets.only(left: 8, top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const AppText(
                                'Fixed Session',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              AppText(
                                '₹500',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
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

                    child:
                        (astro.isAvailableOnline)
                            ? (astro.hasOffer)
                                ? CustomButton(
                                    text: 'Start Session',
                                    fontSize: 10,
                                    height: 32,
                                    backgroundColor: Color(0xFF388E3C),
                                    width: 110,
                                    borderRadius: 8,
                                    onTap: () {
                                      _showStartSessionBottomSheet(context, astro);
                                    },
                                  )
                                : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (astro.isChatEnabled) ...[
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    onTap: () {
                                      final walletController =
                                          Get.find<WalletController>();
                                      final double balance =
                                          double.tryParse(
                                            walletController.balance,
                                          ) ??
                                          0.0;
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
                                  const SizedBox(width: 8),
                                ],
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    onTap: () {
                                      final walletController =
                                          Get.find<WalletController>();
                                      final double balance =
                                          double.tryParse(
                                            walletController.balance,
                                          ) ??
                                          0.0;
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
                            )
                            : Text(
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

  void _showStartSessionBottomSheet(BuildContext context, AstrologerModel astro) {
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
