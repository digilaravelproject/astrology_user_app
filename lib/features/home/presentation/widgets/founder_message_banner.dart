import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_image_widget.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text.dart';
import 'package:astro_user/features/home/presentation/controllers/founder_controller.dart';

class FounderMessageBanner extends StatelessWidget {
  const FounderMessageBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<FounderController>(
      builder: (controller) {
        try {
          if (controller.isLoading.value && controller.founderWords.isEmpty) {
            return const SizedBox.shrink();
          }

          if (controller.founderWords.isEmpty) {
            return const SizedBox.shrink();
          }

          // Extra safety check for empty list before accessing .first
          final words = controller.founderWords;
          if (words.isEmpty) return const SizedBox.shrink();
          
          final word = words.first;
          
          // Debug print to help identify why the circle might be showing
          print('[FounderBanner] Image URL: "${word.image}" | hasImage: ${word.hasImage}');

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFF0F0), // Very light pink
                  Color(0xFFFFF8E1), // Very light gold
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // Decorative background pattern (sparkles)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(Icons.auto_awesome, color: AppColors.goldAccent.withOpacity(0.4), size: 40),
                ),
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: Icon(Icons.star_rate_rounded, color: AppColors.accentColor.withOpacity(0.2), size: 30),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Founder Image (Only show if valid URL exists)
                      if (word.hasImage) ...[
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.goldAccent, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CustomImageWidget(
                            imagePath: word.image, 
                            height: 50,
                            width: 50,
                            radius: BorderRadius.circular(35),
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      
                      // Text Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              word.title.tr,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF8B0000), // Dark Red
                            ),
                            const SizedBox(height: 8),
                            AppText(
                              word.message.tr,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87.withOpacity(0.7),
                              height: 1.4,
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: AppText(
                                AppStrings.yourFounder,
                                style: GoogleFonts.dancingScript(  // Handwriting style
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } catch (e) {
          print('[FounderMessageBanner] Build Error: $e');
          return const SizedBox.shrink();
        }
      }
    );
  }
}
