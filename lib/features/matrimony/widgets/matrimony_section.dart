import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../screens/matrimony_profile_screen.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import 'package:get/get.dart';
import '../controllers/matrimony_controller.dart';
import '../domain/models/matrimony_profile_model.dart';
import '../../../core/constants/app_urls.dart';
import '../../../core/widgets/custom_image_widget.dart';
import '../../auth/controllers/auth_controller.dart';

class MatrimonySection extends StatelessWidget {
  const MatrimonySection({super.key});

  @override
  Widget build(BuildContext context) {
    final MatrimonyController controller = Get.find<MatrimonyController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Obx(() {
        if (controller.isLoading.value && controller.allProfiles.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(50.0),
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...controller.filteredProfiles
                .map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildCompactCustomerCard(context, p),
                  ),
                )
                .toList(),
            if (controller.filteredProfiles.isEmpty &&
                !controller.isLoading.value)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: AppText(
                    AppStrings.noMatchesFound,
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            // Center(
            //   child: CustomButton(
            //     text: AppStrings.more,
            //     height: 50,
            //     width: 220,
            //     fontSize: 16,
            //     fontWeight: FontWeight.w800,
            //     gradient: const LinearGradient(
            //       colors: [Color(0xFFE91E63), Color(0xFFFF5E9D)],
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //     ),
            //     onTap: () {
            //       // Future: Navigate to full list
            //     },
            //   ),
            // ),
          ],
        );
      }),
    );
  }

  Widget _buildCompactCustomerCard(
    BuildContext context,
    MatrimonyProfileModel data,
  ) {
    final String imageUrl =
        data.profilePhoto != null
            ? '${AppUrls.baseImageUrl}${data.profilePhoto}'
            : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatrimonyProfileScreen(profile: data),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFD1DC), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Image, Age, Location
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryColor,
                                width: 2.0,
                              ),
                            ),
                            child: CustomImageWidget(
                              imagePath: imageUrl,
                              height: 70,
                              width: 70,
                              radius: BorderRadius.circular(35),
                              fallbackWidget: Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 40,
                                  color: AppColors.primaryColor.withOpacity(
                                    0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Image.asset(
                            'assets/icons/verify.png',
                            width: 18,
                            height: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        '${data.age} yrs',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3142),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 2),
                          SizedBox(
                            width: 70,
                            child: AppText(
                              data.location.split(',').first,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF7F8487),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Details Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and Verified Icon
                        Row(
                          children: [
                            Expanded(
                              child: AppText(
                                '${data.firstName} ${data.lastName}'
                                    .split(' ')
                                    .map(
                                      (word) =>
                                          word.isNotEmpty
                                              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                                              : '',
                                    )
                                    .join(' '),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2D3142),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        AppText(
                          data.maritalStatus.tr,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7F8487),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 1,
                          color: Colors.grey.withOpacity(0.1),
                        ),
                        const SizedBox(height: 8),

                        // Secondary Details
                        _buildDetailItem(
                          Icons.translate,
                          'Mother Tongue',
                          null,
                        ),

                        const SizedBox(height: 6),
                        _buildDetailItem(
                          Icons.school_outlined,
                          'Education',
                          data.education,
                        ),
                        const SizedBox(height: 6),
                        _buildDetailItem(
                          Icons.work_outline,
                          'Profession',
                          data.jobTitle,
                        ),

                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomButton(
                              text: AppStrings.viewProfile,
                              height: 30,
                              width: 100,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              icon: Icons.chevron_right,
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryColor,
                                  AppColors.secondaryColor,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => MatrimonyProfileScreen(
                                          profile: data,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildDetailItem(IconData icon, String label, String? value) {
    final displayValue =
        (value == null ||
                value.isEmpty ||
                value.toLowerCase() == 'not specified')
            ? 'N/A'
            : value;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 12,
            color: AppColors.primaryColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2D3142).withOpacity(0.6),
              ),
              children: [
                TextSpan(text: '${label.tr}: '),
                TextSpan(
                  text: displayValue.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
