import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMyProfile();
    });
  }

  void _loadMyProfile() {
    final userId = _authController.currentUser.value?.id;

    if (userId == null) {
      return;
    }
    _controller.getMyMatrimonyProfileDetails(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          'My Profile',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              final profile = _controller.selectedProfile.value;
              if (profile != null) {
                Get.to(
                  () => MatrimonyRegistrationScreen(
                    existingProfile: profile,
                    isEditMode: true,
                    onComplete: () {
                      Get.back();
                      _loadMyProfile();
                    },
                  ),
                );
              }
            },
            icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        final profile = _controller.selectedProfile.value;

        if (profile == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off_rounded, size: 80, color: AppColors.textColorHint),
                const SizedBox(height: 16),
                AppText(
                  'Profile not found',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColorSecondary,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Profile Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Profile Photo
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CustomImageWidget(
                        imagePath: AppUrls.baseImageUrl + (profile.profilePhoto ?? ''),
                        height: 100,
                        width: 100,
                        radius: BorderRadius.circular(50),
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Name
                    AppText(
                      '${profile.firstName} ${profile.lastName}',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    // Age, Gender, Location
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildHeaderChip(Icons.cake_rounded, '${profile.age} Yrs'),
                        _buildHeaderChip(
                          profile.gender.toLowerCase() == 'male' 
                            ? Icons.male_rounded 
                            : Icons.female_rounded,
                          profile.gender,
                        ),
                        _buildHeaderChip(Icons.location_on_rounded, profile.location),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // About Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildSectionCard(
                      title: 'About Me',
                      icon: Icons.auto_awesome_rounded,
                      child: AppText(
                        profile.about.isNotEmpty ? profile.about : 'No description available',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColorSecondary,
                        textAlign: TextAlign.start,
                        height: 1.5,
                      ),
                    ),

                    // Personal Details
                    _buildSectionCard(
                      title: 'Personal Details',
                      icon: Icons.person_rounded,
                      child: Column(
                        children: [
                          _buildDetailRow('Created For', profile.createdFor),
                          _buildDivider(),
                          _buildDetailRow('Date of Birth', _formatDate(profile.dateOfBirth)),
                          _buildDivider(),
                          _buildDetailRow('Height', profile.height),
                          _buildDivider(),
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
                          _buildDivider(),
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
                          _buildDivider(),
                          _buildDetailRow('Job Title', profile.jobTitle),
                          _buildDivider(),
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
                            if (profile.panCardNumber != null) ...[
                              _buildDetailRow('PAN Card', profile.panCardNumber!),
                              if (profile.drivingLicenceNumber != null || profile.aadhaarCardNumber != null) _buildDivider(),
                            ],
                            if (profile.drivingLicenceNumber != null) ...[
                              _buildDetailRow('Driving Licence', profile.drivingLicenceNumber!),
                              if (profile.aadhaarCardNumber != null) _buildDivider(),
                            ],
                            if (profile.aadhaarCardNumber != null)
                              _buildDetailRow('Aadhaar Card', profile.aadhaarCardNumber!),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeaderChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          AppText(
            text,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
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
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 16),
              AppText(
                title,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textColorPrimary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: AppText(
              label,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: AppText(
              value.isNotEmpty ? value : 'Not provided',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textColorPrimary,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(color: AppColors.dividerColor.withOpacity(0.5), height: 1),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Not provided';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  // Shimmer loading
  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 350,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildShimmerCircle(130),
                  const SizedBox(height: 16),
                  _buildShimmerBox(200, 28),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildShimmerBox(80, 36, borderRadius: 24),
                      const SizedBox(width: 12),
                      _buildShimmerBox(80, 36, borderRadius: 24),
                      const SizedBox(width: 12),
                      _buildShimmerBox(80, 36, borderRadius: 24),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildShimmerSectionCard(),
                _buildShimmerSectionCard(),
                _buildShimmerSectionCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lightPink,
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
        color: AppColors.lightPink,
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
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildShimmerBox(40, 40, borderRadius: 12),
              const SizedBox(width: 16),
              _buildShimmerBox(150, 24),
            ],
          ),
          const SizedBox(height: 20),
          _buildShimmerBox(double.infinity, 16),
          const SizedBox(height: 12),
          _buildShimmerBox(double.infinity, 16),
          const SizedBox(height: 12),
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
                  AppColors.lightPink.withOpacity(0.5),
                  Colors.white.withOpacity(0.8),
                  AppColors.lightPink.withOpacity(0.5),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }
}
