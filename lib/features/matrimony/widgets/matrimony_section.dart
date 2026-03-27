import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/matrimony_profile_screen.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import 'package:get/get.dart';
import '../controllers/matrimony_controller.dart';
import '../domain/models/matrimony_profile_model.dart';
import '../../../core/constants/app_urls.dart';
import '../../auth/controllers/auth_controller.dart';


class MatrimonySection extends StatelessWidget {
  const MatrimonySection({super.key});

  @override
  Widget build(BuildContext context) {
    final MatrimonyController controller = Get.find<MatrimonyController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Obx(() {
        if (controller.isLoading.value && controller.allProfiles.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(50.0),
              child: CircularProgressIndicator(color: Color(0xFFE91E63)),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...controller.filteredProfiles.map((p) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildCompactCustomerCard(context, p),
                )).toList(),
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
      }
        ),
    );
  }



  Widget _buildCompactCustomerCard(BuildContext context, MatrimonyProfileModel data) {
    final String imageUrl = data.profilePhoto != null 
        ? '${AppUrls.baseImageUrl}${data.profilePhoto}'
        : (data.gender.toLowerCase() == 'male' 
            ? 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png' 
            : 'https://cdn-icons-png.flaticon.com/512/3135/3135768.png');

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
          color: const Color(0xFFFFF0F5), // Soft Pink Card
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
                  // Premium Profile Image
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        // padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE91E63),
                            width: 2.0,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: NetworkImage(imageUrl),
                          ),

                        ),
                      ),
                      Image.asset(
                        'assets/icons/verify.png',
                        width: 22,
                        height: 22,
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  
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
                                '${data.firstName} ${data.lastName}',
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
                        
                        // Age, Religion, Caste
                        Row(
                          children: [
                            const Text('🇮🇳 ', style: TextStyle(fontSize: 12)),
                            Expanded(
                              child: AppText(
                                '${data.age} ${AppStrings.yrs.toLowerCase()}, ${data.maritalStatus}',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF7F8487),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Location
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFFE91E63)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: AppText(
                                data.location,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF7F8487),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        Container(height: 1, color: Colors.grey.withOpacity(0.1)),
                        const SizedBox(height: 8),

                        // Secondary Details
                        _buildDetailItem(Icons.translate, 'Mother Tongue: Not specified'), 

                        const SizedBox(height: 4),
                        _buildDetailItem(Icons.school_outlined, data.education),
                        const SizedBox(height: 4),
                        _buildDetailItem(Icons.work_outline, data.jobTitle),

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
                               colors: [Color(0xFFE91E63), Color(0xFFFF5E9D)],
                               begin: Alignment.topLeft,
                               end: Alignment.bottomRight,
                             ),
                             onTap: () {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) => MatrimonyProfileScreen(profile: data),
                                 ),
                               );
                             },
                           ),
                         ],
                       )
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

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF2D3142).withOpacity(0.6)),
        const SizedBox(width: 8),
        Expanded(
          child: AppText(
            text,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF2D3142).withOpacity(0.8),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
