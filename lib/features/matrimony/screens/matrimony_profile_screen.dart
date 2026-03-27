import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../core/widgets/app_text.dart';
import '../domain/models/matrimony_profile_model.dart';
import '../../../core/constants/app_urls.dart';
import '../controllers/matrimony_controller.dart';
import 'package:get/get.dart';



class MatrimonyProfileScreen extends StatefulWidget {
  final MatrimonyProfileModel profile;

  const MatrimonyProfileScreen({super.key, required this.profile});


  @override
  State<MatrimonyProfileScreen> createState() => _MatrimonyProfileScreenState();
}

class _MatrimonyProfileScreenState extends State<MatrimonyProfileScreen> {
  final MatrimonyController _controller = Get.find<MatrimonyController>();
  bool _showDetails = false;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  Timer? _autoSlideTimer;

  
  List<String> _getImages(MatrimonyProfileModel profile) {
    final baseUrl = AppUrls.baseImageUrl;
    if (profile.profilePhoto != null) {
      return ['$baseUrl${profile.profilePhoto}'];
    }
    return [
      profile.gender.toLowerCase() == 'male' 
          ? 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png' 
          : 'https://cdn-icons-png.flaticon.com/512/3135/3135768.png'
    ];
  }



  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    if (widget.profile.id != null) {
      _controller.getMatrimonyProfileDetails(widget.profile.id!);
    }
  }


  void _startAutoSlide() {
    final profile = _controller.selectedProfile.value ?? widget.profile;
    final images = _getImages(profile);
    
    if (images.length <= 1) return;

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final currentImages = _getImages(_controller.selectedProfile.value ?? widget.profile);
        if (currentImages.length <= 1) {
          timer.cancel();
          return;
        }
        int nextPage = (_currentImageIndex + 1) % currentImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }


  void _stopAutoSlide() {
    _autoSlideTimer?.cancel();
  }

  @override
  void dispose() {
    _stopAutoSlide();
    _pageController.dispose();
    super.dispose();
  }

  void _showFullScreenImage(int index, MatrimonyProfileModel profile) {
    final images = _getImages(profile);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(
          images: images,
          initialIndex: index,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF880E4F)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.more_vert, color: Color(0xFF880E4F)),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 12),
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildMenuOption(
                            context,
                            Icons.share_outlined,
                            'Share Profile',
                            () {
                              Navigator.pop(context);
                              _shareProfile();
                            },
                          ),
                          _buildMenuOption(
                            context,
                            Icons.bookmark_border,
                            'Save Profile',
                            () {
                              Navigator.pop(context);
                              _saveProfile();
                            },
                          ),
                          _buildMenuOption(
                            context,
                            Icons.block_outlined,
                            'Block User',
                            () {
                              Navigator.pop(context);
                              _blockUser(context);
                            },
                          ),
                          _buildMenuOption(
                            context,
                            Icons.report_outlined,
                            'Report Profile',
                            () {
                              Navigator.pop(context);
                              _reportProfile(context);
                            },
                            isLast: true,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.selectedProfile.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE91E63)),
          );
        }

        final profile = _controller.selectedProfile.value ?? widget.profile;
        
        return _showDetails
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileHeader(profile),
                    const SizedBox(height: 16),
                    _buildPersonalInformation(profile),
                    const SizedBox(height: 16),
                    _buildContactInformation(profile),
                    const SizedBox(height: 16),
                    _buildAboutMyself(profile),
                    const SizedBox(height: 16),
                    _buildLifestyle(profile),
                    const SizedBox(height: 16),
                    _buildPartnerPreferencesHeader(profile),
                    const SizedBox(height: 16),
                    _buildIgnoredSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              )
            : SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: _buildProfileHeader(profile),
              );
      }),
    );
  }

  Widget _buildProfileHeader(MatrimonyProfileModel profile) {
    return Container(

      color: Colors.white,
      child: Column(
        children: [
          // Profile Image with rounded bottom corners
          Stack(
            children: [
              GestureDetector(
                onTap: () => _showFullScreenImage(_currentImageIndex, profile),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: double.infinity,
                  child: _getImages(profile).length > 1
                      ? PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemCount: _getImages(profile).length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30),
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(_getImages(profile)[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(_getImages(profile)[0]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                ),
              ),
              // Page indicators (Only show for multiple images)
              if (_getImages(profile).length > 1)
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _getImages(profile).length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentImageIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentImageIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              // Image counter (Only show for multiple images)
              if (_getImages(profile).length > 1)
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AppText(
                        '${_currentImageIndex + 1}/${_getImages(profile).length}',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),


              // Action buttons overlay
              Positioned(
                bottom: 50,
                right: 16,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.call, color: Color(0xFFE91E63), size: 22),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.chat_bubble, color: Color(0xFF4CAF50), size: 22),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Profile Details Card
          Transform.translate(
            offset: const Offset(0, -20),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          '${profile.firstName} ${profile.lastName}',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF880E4F),
                          height: 1.3,
                        ),

                      ),
                      Image.asset(
                        'assets/icons/verify.png',
                        width: 28,
                        height: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppText(
                          'ID: MT${profile.id ?? ""}',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE91E63),
                        ),


                      ),
                      const SizedBox(width: 10),
                      // Icon(Icons.circle, size: 4, color: Colors.grey[400]),
                      // const SizedBox(width: 10),
                      // Expanded(
                      //   child: AppText(
                      //     'Last seen few hours ago',
                      //     fontSize: 12,
                      //     fontWeight: FontWeight.w500,
                      //     color: Colors.grey[600],
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey[200], thickness: 1),
                  const SizedBox(height: 16),
                  _buildQuickInfo(Icons.favorite_border, profile.maritalStatus),
                  const SizedBox(height: 10),
                  _buildQuickInfo(Icons.cake_outlined, '${profile.age} Years  • ${profile.height} Feet'),

                  const SizedBox(height: 10),
                  _buildQuickInfo(Icons.school_outlined, profile.education),
                  const SizedBox(height: 10),
                  _buildQuickInfo(Icons.work_outline, profile.jobTitle),

                  const SizedBox(height: 10),
                  _buildQuickInfo(Icons.location_on_outlined, profile.location),


                  const SizedBox(height: 20),
                  CustomButton(
                    fontSize: 16,
                    text: _showDetails ? 'Hide Details' : AppStrings.viewPersonalInformation,
                    onTap: () {
                      setState(() {
                        _showDetails = !_showDetails;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF880E4F)),
        const SizedBox(width: 12),
        Expanded(
          child: AppText(
            text,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  void _shareProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile shared successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile saved to your favorites!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _blockUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const AppText(
          'Block User',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF880E4F),
        ),
        content: const AppText(
          'Are you sure you want to block this user? You won\'t be able to see their profile or receive messages from them.',
          fontSize: 14,
          color: Colors.black87,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText(
              'Cancel',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User blocked successfully'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(20),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const AppText(
              'Block',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _reportProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const AppText(
              'Report Profile',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF880E4F),
            ),
            const SizedBox(height: 8),
            const AppText(
              'Please select a reason for reporting this profile',
              fontSize: 13,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            _buildReportOption(context, 'Fake Profile'),
            _buildReportOption(context, 'Inappropriate Content'),
            _buildReportOption(context, 'Harassment'),
            _buildReportOption(context, 'Spam'),
            _buildReportOption(context, 'Other'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReportOption(BuildContext context, String reason) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile reported for: $reason'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.flag_outlined, color: Colors.grey[600], size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: AppText(
                reason,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF880E4F), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: AppText(
                title,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String text, {bool isFirst = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: AppText(
        text,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF6A1B9A),
        height: 1.4,
      ),
    );
  }

  Widget _buildPersonalInformation(MatrimonyProfileModel profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),

      padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE91E63).withOpacity(0.2), Color(0xFFAD1457).withOpacity(0.2)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, color: Color(0xFF880E4F), size: 22),
              ),
              const SizedBox(width: 12),
              AppText(
                AppStrings.personalInformation,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF880E4F),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow(AppStrings.age, '${profile.age} Years'),
          _buildDetailRow(AppStrings.height, '${profile.height} Feet'),
          _buildDetailRow(AppStrings.spokenLanguages, 'Not specified'),
          _buildDetailRow(AppStrings.profileCreatedBy, profile.createdFor),
          _buildDetailRow(AppStrings.maritalStatus, profile.maritalStatus),
          _buildDetailRow(AppStrings.livesIn, profile.location),
          _buildDetailRow(AppStrings.eatingHabits, 'Not specified'),
          _buildDetailRow(AppStrings.religion, 'Not specified'),
          _buildDetailRow(AppStrings.subcaste, 'Not specified'),
          _buildDetailRow(AppStrings.manglik, 'Not specified'),
          _buildDetailRow(AppStrings.employment, profile.jobTitle, isLink: true),


        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: AppText(
              label,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const AppText(':  '),
          Expanded(
            child: AppText(
              value,
              fontSize: 14,
              fontWeight: isLink ? FontWeight.w500 : FontWeight.w600,
              color: isLink ? const Color(0xFFE91E63) : const Color(0xFF212121),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInformation(MatrimonyProfileModel profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE91E63).withOpacity(0.2), Color(0xFFAD1457).withOpacity(0.2)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone_outlined, color: Color(0xFF880E4F), size: 22),
              ),
              const SizedBox(width: 12),
              AppText(
                AppStrings.contactInformation,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF880E4F),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              AppText(
                AppStrings.mobileNumber,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 24),
              const AppText(':  '),
              AppText(
                profile.phone,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 12),

          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 14, color: Color(0xFFE91E63)),
                const SizedBox(width: 4),
                AppText(
                  AppStrings.upgradeToView,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFE91E63),
                ),
                const Icon(Icons.chevron_right, size: 16, color: Color(0xFFE91E63)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutMyself(MatrimonyProfileModel profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),

      padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE91E63).withOpacity(0.2), Color(0xFFAD1457).withOpacity(0.2)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline, color: Color(0xFF880E4F), size: 22),
              ),
              const SizedBox(width: 12),
              AppText(
                AppStrings.aboutMyself,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF880E4F),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppText(
            profile.about,
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
            height: 1.3,
          ),


        ],
      ),
    );
  }

  Widget _buildLifestyle(MatrimonyProfileModel profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),

      padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE91E63).withOpacity(0.2), Color(0xFFAD1457).withOpacity(0.2)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_outline, color: Color(0xFF880E4F), size: 22),
              ),
              const SizedBox(width: 12),
              AppText(
                AppStrings.lifestyle,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF880E4F),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(AppStrings.cuisine, "I'm a foodie, Konkan"),
          _buildDetailRow(AppStrings.hobbies, 'Cooking, Nature, Photography'),
          _buildDetailRow(AppStrings.music, 'Indian classical'),
          _buildDetailRow(AppStrings.sports, "I'm not a sportsperson"),
          _buildDetailRow(AppStrings.smokingHabits, 'Not specified'),
          _buildDetailRow(AppStrings.drinkingHabits, 'Not specified'),
        ],
      ),
    );
  }

  Widget _buildPartnerPreferencesHeader(MatrimonyProfileModel profile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star, color: Color(0xFFE1BEE7), size: 20), // Placeholder for sparkles
          const SizedBox(width: 8),
          AppText(
            profile.gender.toLowerCase() == 'male' 
                ? AppStrings.hisPartnerPreferences 
                : AppStrings.herPartnerPreferences,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF880E4F),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.star, color: Color(0xFFE1BEE7), size: 20),
        ],
      ),
    );
  }


  Widget _buildIgnoredSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            AppStrings.youIgnoredThisProfile,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF880E4F),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.5)),
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: AppText(
              AppStrings.removeFromIgnoredList,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF880E4F),
            ),
          ),
        ],
      ),
    );
  }
}


// Full Screen Image Viewer
class _FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          // Close button
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          // Image counter
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: AppText(
                '${_currentIndex + 1}/${widget.images.length}',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          // Page indicators
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
