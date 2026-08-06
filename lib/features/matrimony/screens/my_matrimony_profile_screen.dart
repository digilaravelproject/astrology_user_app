import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_image_widget.dart';
import '../controllers/matrimony_controller.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import 'matrimony_registration_screen.dart';

class MyMatrimonyProfileScreen extends StatefulWidget {
  const MyMatrimonyProfileScreen({super.key});

  @override
  State<MyMatrimonyProfileScreen> createState() => _MyMatrimonyProfileScreenState();
}

class _MyMatrimonyProfileScreenState extends State<MyMatrimonyProfileScreen> {
  final MatrimonyController _controller = Get.find<MatrimonyController>();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to call API after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMyProfile();
    });
  }

  void _loadMyProfile() {
    final userId = _authController.currentUser.value?.id;

    print("userId : ${userId.toString()}");
    if (userId == null) {
      print('User ID is null, cannot load profile');
      return;
    }

    print('Loading my matrimony profile for userId: $userId');
    // Use the new API that fetches profile by user ID directly
    _controller.getMyMatrimonyProfileDetails(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2D3142), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          'My Profile',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2D3142),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                final profile = _controller.selectedProfile.value;
                if (profile != null) {
                  Get.to(
                    () => MatrimonyRegistrationScreen(
                      existingProfile: profile,
                      isEditMode: true,
                      onComplete: () {
                        Get.back(); // Go back to my profile screen
                        _loadMyProfile(); // Reload the profile
                      },
                    ),
                  );
                }
              },
              icon: const Icon(Icons.edit_rounded, color: AppColors.primaryColor, size: 18),
              label: const AppText(
                'Edit',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header Shimmer
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Profile Photo Shimmer
                      _buildShimmerCircle(120),
                      const SizedBox(height: 16),
                      // Name Shimmer
                      _buildShimmerBox(200, 24),
                      const SizedBox(height: 8),
                      // Info Chips Shimmer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildShimmerBox(80, 30, borderRadius: 20),
                          const SizedBox(width: 12),
                          _buildShimmerBox(80, 30, borderRadius: 20),
                          const SizedBox(width: 12),
                          _buildShimmerBox(80, 30, borderRadius: 20),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Section Cards Shimmer
                _buildShimmerSectionCard(),
                _buildShimmerSectionCard(),
                _buildShimmerSectionCard(),
                _buildShimmerSectionCard(),
                const SizedBox(height: 24),
              ],
            ),
          );
        }

        final profile = _controller.selectedProfile.value;

        if (profile == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off_rounded, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                AppText(
                  'Profile not found',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header Card
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Profile Photo
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryColor,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CustomImageWidget(
                        imagePath: AppUrls.baseImageUrl+profile.profilePhoto.toString() ?? '',
                        height: 120,
                        width: 120,
                        radius: BorderRadius.circular(60),
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name
                    AppText(
                      '${profile.firstName} ${profile.lastName}',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2D3142),
                    ),
                    const SizedBox(height: 8),
                    // Age, Gender, Location
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildInfoChip(Icons.cake_rounded, '${profile.age} years'),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          profile.gender.toLowerCase() == 'male' 
                            ? Icons.male_rounded 
                            : Icons.female_rounded,
                          profile.gender,
                        ),
                        const SizedBox(width: 12),
                        _buildInfoChip(Icons.location_on_rounded, profile.location),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // About Section
              _buildSectionCard(
                title: 'About Me',
                icon: Icons.info_rounded,
                child: AppText(
                  profile.about.isNotEmpty ? profile.about : 'No description available',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                  textAlign: TextAlign.start,
                ),
              ),

              // Personal Details
              _buildSectionCard(
                title: 'Personal Details',
                icon: Icons.person_rounded,
                child: Column(
                  children: [
                    _buildDetailRow('Created For', profile.createdFor),
                    _buildDetailRow('Date of Birth', profile.dateOfBirth),
                    _buildDetailRow('Height', profile.height),
                    _buildDetailRow('Marital Status', profile.maritalStatus),
                  ],
                ),
              ),

              // Contact Information
              _buildSectionCard(
                title: 'Contact Information',
                icon: Icons.contact_phone_rounded,
                child: Column(
                  children: [
                    _buildDetailRow('Email', profile.email),
                    _buildDetailRow('Phone', profile.phone),
                  ],
                ),
              ),

              // Professional Details
              _buildSectionCard(
                title: 'Professional Details',
                icon: Icons.work_rounded,
                child: Column(
                  children: [
                    _buildDetailRow('Education', profile.education),
                    _buildDetailRow('Job Title', profile.jobTitle),
                    _buildDetailRow('Annual Income', profile.annualIncome),
                  ],
                ),
              ),

              // Document Details (if available)
              if (profile.panCardNumber != null || 
                  profile.drivingLicenceNumber != null || 
                  profile.aadhaarCardNumber != null)
                _buildSectionCard(
                  title: 'Document Details',
                  icon: Icons.description_rounded,
                  child: Column(
                    children: [
                      if (profile.panCardNumber != null)
                        _buildDetailRow('PAN Card', profile.panCardNumber!),
                      if (profile.drivingLicenceNumber != null)
                        _buildDetailRow('Driving Licence', profile.drivingLicenceNumber!),
                      if (profile.aadhaarCardNumber != null)
                        _buildDetailRow('Aadhaar Card', profile.aadhaarCardNumber!),
                    ],
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryColor),
          const SizedBox(width: 4),
          AppText(
            text,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3142),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppColors.primaryColor),
              ),
              const SizedBox(width: 12),
              AppText(
                title,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3142),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: AppText(
              label,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: AppText(
              value.isNotEmpty ? value : 'Not provided',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2D3142),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // Shimmer effect widgets
  Widget _buildShimmerCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: ClipOval(
        child: _buildShimmerGradient(),
      ),
    );
  }

  Widget _buildShimmerBox(double width, double height, {double borderRadius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: _buildShimmerGradient(),
      ),
    );
  }

  Widget _buildShimmerSectionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildShimmerCircle(40),
              const SizedBox(width: 12),
              _buildShimmerBox(120, 20),
            ],
          ),
          const SizedBox(height: 16),
          _buildShimmerBox(double.infinity, 16),
          const SizedBox(height: 8),
          _buildShimmerBox(double.infinity, 16),
          const SizedBox(height: 8),
          _buildShimmerBox(200, 16),
        ],
      ),
    );
  }

  Widget _buildShimmerGradient() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: 2.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return FractionallySizedBox(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(value - 1, 0),
                end: Alignment(value, 0),
                colors: [
                  Colors.grey[300]!,
                  Colors.grey[100]!,
                  Colors.grey[300]!,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
      onEnd: () {
        // Restart animation
        if (mounted) {
          setState(() {});
        }
      },
    );
  }
}
