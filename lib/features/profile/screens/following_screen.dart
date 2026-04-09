import 'package:astro_user/core/constants/app_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../controllers/profile_controller.dart';
import '../../astrologers/screens/astrologer_detail_screen.dart';
import '../../astrologers/bindings/astrologers_binding.dart';
import '../../astrologers/controllers/astrologer_controller.dart';
import '../../../core/widgets/custom_image_widget.dart';
import '../../../core/utils/custom_snackbar.dart';

class FollowingScreen extends StatelessWidget {
  const FollowingScreen({super.key});

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
    ));
    
    // Fetch following list when screen is accessed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchFollowing();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background for better card contrast
      appBar: CustomAppBar(
        title: AppStrings.following,
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Obx(() {
        if (profileController.isLoading.value && profileController.followingList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final followingList = profileController.followingList;

        if (followingList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightPink.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.deepPink,
                  ),
                ),
                const SizedBox(height: 20),
                AppText(
                  'No Following',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                const SizedBox(height: 8),
                AppText(
                  'You are not following any astrologer yet.',
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
          itemCount: followingList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildAstrologerCard(followingList[index], profileController, astrologerController);
          },
        );
      }),
    );
  }

  Widget _buildAstrologerCard(dynamic astro, ProfileController profileController, AstrologerController astrologerController) {
    final imageUrl = astro['profile_photo'] != null 
        ? AppUrls.baseImageUrl+astro['profile_photo']
        : null;
    
    return GestureDetector(
      onTap: () {
        // Navigate to astrologer detail screen
        Get.to(
          () => AstrologerDetailScreen(astrologerId: astro['astrologer_id'] ?? astro['user_id'] ?? 0),
          binding: AstrologersBinding(),
          transition: Transition.rightToLeft,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            // Profile Image with Online Status
            Stack(
              children: [
                Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.deepPink.withOpacity(0.2), width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl != null 
                      ? CustomImageWidget(
                          imagePath: imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppColors.lightPink,
                          child: const Icon(Icons.person, color: AppColors.primaryColor, size: 36),
                        ),
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    height: 14,
                    width: 14,
                    decoration: BoxDecoration(
                      color: (astro['is_online'] == true || astro['is_online'] == 1) ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: AppText(
                          (astro['name']?.toString() ?? '').split(' ').map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}' : '').join(' '),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E1A47),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: Colors.blue, size: 14),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    (astro['areas_of_expertise'] as List?)?.join(' • ') ?? '',
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Iconsax.star_1, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      AppText(
                        astro['avg_rating']?.toString() ?? '0',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 12),
                      Icon(Iconsax.global, size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Flexible(
                        child: AppText(
                          (astro['languages'] as List?)?.join(', ') ?? '',
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action Button
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                final id = astro['astrologer_id'] ?? astro['user_id'] ?? 0;
                if (id != 0) {
                  final response = await astrologerController.followAstrologer(id);
                  if (response.isSuccess) {
                    CustomSnackbar.showSuccess(response.message);
                    profileController.fetchFollowing();
                  } else {
                    CustomSnackbar.showError(response.message);
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.lightPink.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.deepPink.withOpacity(0.3)),
                ),
                child: AppText(
                  "Following",
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepPink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
