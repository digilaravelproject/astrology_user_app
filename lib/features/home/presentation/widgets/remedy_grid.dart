import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_image_widget.dart';
import 'package:astro_user/features/remedy/presentation/screens/remedy_detail_screen.dart';
import 'package:astro_user/features/home/presentation/controllers/remedy_controller.dart';
import 'package:astro_user/features/home/data/models/remedy_model.dart';
import 'package:astro_user/features/remedy/presentation/screens/remedy_list_screen.dart';

class RemedyGrid extends StatelessWidget {
  const RemedyGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final remedyController = Get.find<RemedyController>();

    return Obx(() {
      if (remedyController.isLoading.value) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 155,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                width: 115,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }

      if (remedyController.remedies.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F2), // Light peach background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.spa, color: Color(0xFFB57E2F), size: 20), // Golden lotus-like icon
                      const SizedBox(width: 8),
                      AppText('Remedies'.tr,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5D1E2D), // Deep burgundy color
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const RemedyListScreen());
                    },
                    child: Row(
                      children: [
                        AppText('View All'.tr,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5D1E2D),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF5D1E2D)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Grid
            SizedBox(
              height: 155,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: remedyController.remedies.length,
                itemBuilder: (context, index) {
                  final remedy = remedyController.remedies[index];
                  final imageUrl = remedy.image ?? remedyController.getRemedyImage(index);
                  
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => RemedyDetailScreen(
                        remedyId: remedy.id,
                        accentColor: AppColors.primaryColor,
                        imageUrl: imageUrl,
                      ));
                    },
                    child: Container(
                      width: 115,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: CustomImageWidget(
                              imagePath: imageUrl,
                              height: 95,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: AppText(
                              remedy.title,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF5D1E2D),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 2,
                            width: 24,
                            color: const Color(0xFFB57E2F), // Golden underline
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    });
  }
}
