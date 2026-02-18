import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../astrologers/screens/astrologer_detail_screen.dart';

class FollowingScreen extends StatelessWidget {
  const FollowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background for better card contrast
      appBar: CustomAppBar(
        title: AppStrings.following,
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildAstrologerCard(index);
        },
      ),
    );
  }

  Widget _buildAstrologerCard(int index) {
    const imageUrl = "https://theblunttimes.in/wp-content/uploads/2024/02/astro-1.jpg";
    
    return GestureDetector(
      onTap: () {
        Get.to(() => AstrologerDetailScreen(
          name: "Astrologer ${index + 1}",
          skills: "Vedic • Tarot • Palmistry",
          languages: "English, Hindi",
          experience: "1${index + 2} Years",
          rating: 4.9,
          price: "50",
          discountPrice: "30",
          orders: "50${index}0",
          minutes: "2000",
          imageUrl: imageUrl,
          bio: "Expert in Vedic Astrology and Tarot Reading with over 10 years of experience.",
          isRisingStar: index % 2 == 0,
          isVerified: true,
        ));
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
                    image: const DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    height: 14,
                    width: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
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
                          "Astrologer ${index + 1}",
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
                    "Vedic • Tarot • Palmistry",
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
                        "4.9",
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 12),
                      Icon(Iconsax.global, size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Flexible(
                        child: AppText(
                          "English, Hindi",
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
            Container(
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
          ],
        ),
      ),
    );
  }
}
