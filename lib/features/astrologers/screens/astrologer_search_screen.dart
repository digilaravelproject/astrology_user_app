import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_image_widget.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_rating_bar.dart';
import '../controllers/astrologer_controller.dart';
import '../domain/models/astrologer_model.dart';
import '../screens/astrologer_detail_screen.dart';
import '../bindings/astrologers_binding.dart';
import '../../../core/utils/wallet_helper.dart';
import '../../../core/widgets/custom_button.dart';

class AstrologerSearchScreen extends StatefulWidget {
  final String? serviceType;
  const AstrologerSearchScreen({super.key, this.serviceType});

  @override
  State<AstrologerSearchScreen> createState() => _AstrologerSearchScreenState();
}

class _AstrologerSearchScreenState extends State<AstrologerSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AstrologerController controller = Get.find<AstrologerController>();

  @override
  void initState() {
    super.initState();
    // Clear previous results on open
    controller.searchResults.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Container(
          margin: const EdgeInsets.only(right: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) {
                    if (value.length > 2) {
                      controller.searchAstrologers(
                          query: value, serviceType: widget.serviceType);
                    } else {
                      controller.searchResults.clear();
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none, // Remove pink outline
                    enabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              Obx(() => controller.isSearchLoading.value
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primaryColor),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (controller.searchResults.isEmpty &&
            _searchController.text.length > 2 &&
            !controller.isSearchLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.search_status_copy,
                    size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                AppText('No astrologers found',
                    color: Colors.grey.shade500, fontSize: 16),
              ],
            ),
          );
        }

        if (controller.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.message_search_copy,
                    size: 64, color: Colors.grey.shade200),
                const SizedBox(height: 16),
                AppText('Start typing to search...',
                    color: Colors.grey.shade400, fontSize: 14),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
            return _buildAstrologerCard(
                context, controller.searchResults[index]);
          },
        );
      }),
    );
  }

  Widget _buildAstrologerCard(BuildContext context, AstrologerModel astro) {
    bool isCall = widget.serviceType == 'call';

    return GestureDetector(
      onTap: () {
        Get.to(
          () => AstrologerDetailScreen(astrologerId: astro.id),
          binding: AstrologersBinding(),
          transition: Transition.rightToLeft,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.deepPink.withOpacity(0.2),
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
                Stack(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.goldAccent,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: astro.profilePhoto != null &&
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
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomRatingBar(
                  rating: astro.rating,
                  size: 15,
                ),
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
                    children: [
                      AppText(
                        astro.name,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Colors.green,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  AppText(
                    astro.areasOfExpertise.join(', '),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppText(
                    astro.languages.join(', '),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppText(
                    '${AppStrings.expLabelPrefix} ${astro.yearsOfExperience} ${AppStrings.years}',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    text: isCall
                        ? '${AppStrings.call} - ₹${astro.callRate ?? '0'}/min'
                        : '${AppStrings.chat} - ₹${astro.chatRate ?? '0'}/min',
                    icon: isCall ? Icons.call : Icons.chat,
                    fontSize: 11,
                    height: 32,
                    borderRadius: 8,
                    backgroundColor: Colors.transparent,
                    textColor: const Color(0xFF4CAF50),
                    borderColor: const Color(0xFF4CAF50),
                    onTap: () => WalletHelper.checkBalanceAndProceed(
                      context: context,
                      type: isCall ? 'call' : 'chat',
                      name: astro.name,
                      imageUrl: astro.fullProfilePhoto,
                      price: (isCall ? astro.callRate : astro.chatRate) ?? '0',
                      providerId: astro.userId,
                      simulatedBalance: 10.0,
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

  Widget _buildPlaceholderLarge() {
    return Container(
      color: AppColors.lightPink,
      child: const Icon(
        Icons.person,
        color: AppColors.primaryColor,
        size: 50,
      ),
    );
  }
}
