import 'package:astro_user/core/constants/app_urls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:astro_user/core/widgets/custom_app_bar.dart';
import 'package:astro_user/core/widgets/custom_rating_bar.dart';
import 'package:astro_user/core/constants/app_strings.dart';
import 'package:astro_user/features/profile/presentation/controllers/profile_controller.dart';
import 'package:astro_user/features/astrologers/presentation/screens/astrologer_detail_screen.dart';
import 'package:astro_user/features/astrologers/presentation/bindings/astrologers_binding.dart';
import 'package:astro_user/features/astrologers/presentation/controllers/astrologer_controller.dart';
import 'package:astro_user/core/widgets/custom_image_widget.dart';
import 'package:astro_user/core/utils/custom_snackbar.dart';

class BlockedAstrologersScreen extends StatelessWidget {
  const BlockedAstrologersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    final astrologerController = Get.put(AstrologerController(
      getAstrologersUseCase: Get.find(),
      getAstrologerByIdUseCase: Get.find(),
      blockAstrologerUseCase: Get.find(),
      reportAstrologerUseCase: Get.find(),
      postReviewUseCase: Get.find(),
      getReviewsUseCase: Get.find(),
      followAstrologerUseCase: Get.find(),
      getGiftsUseCase: Get.find(),
      sendGiftUseCase: Get.find(),
      getGiftHistoryUseCase: Get.find(),
      getAstrologerGalleryUseCase: Get.find(),
    ));

    // Fetch blocked list when screen is accessed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchBlocked();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomAppBar(
        title: 'Blocked Astrologers'.tr,
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Obx(() {
        if (profileController.isLoading.value && profileController.blockedList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final blockedList = profileController.blockedList;

        if (blockedList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                  ),
                  child: const Icon(
                    Iconsax.user_remove_copy,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                AppText(
                  'No Blocked Astrologers'.tr,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                const SizedBox(height: 8),
                AppText(
                  'You have not blocked any astrologer yet.'.tr,
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: blockedList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildAstrologerCard(context, blockedList[index], profileController, astrologerController);
          },
        );
      }),
    );
  }

  Widget _buildAstrologerCard(BuildContext context, dynamic astro, ProfileController profileController, AstrologerController astrologerController) {
    final astrologer = astro['astrologer'] ?? astro;
    final userData = astrologer['user'] as Map<String, dynamic>? ?? {};
    
    final int id = astrologer['id'] ?? astrologer['astrologer_id'] ?? astrologer['user_id'] ?? 0;
    final String name = userData['name']?.toString() ?? astrologer['name']?.toString() ?? '';
    final String profilePhoto = astrologer['profile_photo']?.toString() ?? userData['profile_photo']?.toString() ?? '';
    final String imageUrl = profilePhoto.isNotEmpty ? AppUrls.baseImageUrl + profilePhoto : '';
    
    final double rating = double.tryParse(astrologer['rating']?.toString() ?? astrologer['avg_rating']?.toString() ?? '0') ?? 0.0;
    final int totalOrders = int.tryParse(astrologer['total_orders']?.toString() ?? astrologer['orders_count']?.toString() ?? astrologer['completed_orders_count']?.toString() ?? '0') ?? 0;
    final int experience = int.tryParse(astrologer['years_of_experience']?.toString() ?? astrologer['experience']?.toString() ?? '0') ?? 0;
    
    // Expertise & Languages
    final List<dynamic> expertiseList = astrologer['areas_of_expertise'] is List 
        ? astrologer['areas_of_expertise'] 
        : (astrologer['areas_of_expertise']?.toString().split(',') ?? []);
    final String expertise = expertiseList.map((e) => e.toString().trim().tr).where((e) => e.isNotEmpty).join(', ');
    
    final List<dynamic> languagesList = astrologer['languages'] is List 
        ? astrologer['languages'] 
        : (astrologer['languages']?.toString().split(',') ?? []);
    final String languages = languagesList.map((l) => l.toString().trim().tr).where((l) => l.isNotEmpty).join(', ');

    return GestureDetector(
      onTap: () {
        if (id != 0) {
          Get.to(
            () => AstrologerDetailScreen(astrologerId: id),
            binding: AstrologersBinding(),
            transition: Transition.rightToLeft,
          );
        }
      },
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Photo, Rating, and Orders
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
                        child: imageUrl.isNotEmpty
                            ? CustomImageWidget(
                                imagePath: imageUrl,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: AppColors.lightPink,
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.primaryColor,
                                  size: 50,
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: (astrologer['is_online'] == true || astrologer['is_online'] == 1) ? Colors.green : Colors.grey,
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
                const SizedBox(height: 8),
                CustomRatingBar(
                  rating: rating,
                  size: 12,
                ),
                const SizedBox(height: 4),
                AppText(
                  _formatOrdersCount(totalOrders),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ],
            ),
            const SizedBox(width: 12),
            
            // Middle/Right Column: Text Details and Unblock Button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: AppText(
                                name.split(' ').map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}' : '').join(' '),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              color: Colors.green,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                      
                      // Unblock Action Button
                      GestureDetector(
                        onTap: () async {
                          if (id != 0) {
                            final response = await astrologerController.unblockAstrologer(id);
                            if (response.isSuccess) {
                              CustomSnackbar.showSuccess(response.message);
                              profileController.fetchBlocked(showLoader: false);
                              if (Get.isRegistered<AstrologerController>()) {
                                Get.find<AstrologerController>().fetchAstrologers(showLoader: false);
                              }
                            } else {
                              CustomSnackbar.showError(response.message);
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: AppText(
                            "Unblock".tr,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (expertise.isNotEmpty) ...[
                    AppText(
                      expertise,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                  ],
                  if (languages.isNotEmpty) ...[
                    AppText(
                      languages,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                  ],
                  AppText(
                    '${AppStrings.expLabelPrefix} $experience ${"Years".tr}',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatOrdersCount(int count) {
    if (count >= 1000) {
      double inK = count / 1000.0;
      return '${inK.toStringAsFixed(inK.truncateToDouble() == inK ? 0 : 1)}k+ ${AppStrings.ordersLabel}';
    } else if (count > 0) {
      return '$count+ ${AppStrings.ordersLabel}';
    } else {
      return '0 ${AppStrings.ordersLabel}';
    }
  }
}
