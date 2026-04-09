import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_urls.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/widgets/custom_image_widget.dart';
import '../../wallet/screens/wallet_screen.dart';
import '../../history/screens/history_screen.dart';
import 'edit_profile_screen.dart';
import 'change_language_screen.dart';
import '../../../core/widgets/simple_content_screen.dart';
import 'help_support_screen.dart';
import 'faq_screen.dart';
import 'subscription_screen.dart';
import 'astrologer_registration_screen.dart';
import 'referral_screen.dart';
import 'following_screen.dart';
import 'feedback_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100), // Space for bottom nav
        child: Column(
          children: [
            _buildProfileHeader(authController),
            const SizedBox(height: 20),
            _buildMenuItems(context, authController),
            const SizedBox(height: 30),
            _buildActionButtons(authController),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthController authController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFD1D1),
            Color(0xFFFFF8F9),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Close Icon at top right
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  color: AppColors.deepPink,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          
          // Profile Image
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Obx(() {
                  final user = authController.currentUser.value;
                  return CustomImageWidget(
                    imagePath: (() {
                      final photo = user?.profilePhoto;
                      if (photo == null || photo.isEmpty) return null;
                      if (photo.startsWith('http')) return photo;
                      final cleanPhoto = photo.startsWith('/') ? photo.substring(1) : photo;
                      return '${AppUrls.baseImageUrl}$cleanPhoto';
                    })(),
                    height: 100,
                    width: 100,
                    radius: BorderRadius.circular(50),
                    fit: BoxFit.cover,
                    fallbackWidget: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.editProfile),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.deepPink,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Name and Phone
          Obx(() => AppText(
            authController.currentUser.value?.name ?? AppStrings.guest,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E1A47),
          )),
          const SizedBox(height: 4),
          Obx(() => AppText(
            authController.currentUser.value?.mobile ?? "+91 9876543210",
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          )),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, AuthController authController) {
    return Column(
      children: [
        _buildSectionHeader(AppStrings.accountSettings),
        _buildMenuItem(
          icon: Iconsax.timer_1_copy,
          title: AppStrings.navHistory,
          onTap: () => Get.to(() => const HistoryScreen()),
        ),
        _buildMenuItem(
          icon: Icons.translate_rounded,
          title: AppStrings.changeLanguage,
          onTap: () => Get.to(() => const ChangeLanguageScreen()),
        ),
        _buildMenuItem(
          icon: Iconsax.user_copy,
          title: AppStrings.myAccount,
          onTap: () => Get.toNamed(AppRoutes.editProfile),
        ),
        _buildMenuItem(
          icon: Iconsax.wallet_3_copy,
          title: AppStrings.wallet,
          onTap: () => Get.toNamed(AppRoutes.wallet),
        ),
        _buildMenuItem(
          icon: Iconsax.crown_1_copy,
          title: AppStrings.manageSubscription,
          onTap: () => Get.toNamed(AppRoutes.subscriptionScreen),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: AppText(AppStrings.proBadge, fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber[800]),
          ),
        ),
        // _buildMenuItem(
        //   icon: Iconsax.arrow_circle_up_copy,
        //   title: AppStrings.upgradePlan,
        //   onTap: () => Get.toNamed(AppRoutes.subscriptionScreen),
        // ),
        
        const SizedBox(height: 10),
        _buildSectionHeader(AppStrings.referralsCommunity),
        // _buildMenuItem(
        //   icon: Iconsax.gift_copy,
        //   title: AppStrings.referAndEarn,
        //   onTap: () => Get.to(() => const ReferralScreen()),
        // ),
        _buildMenuItem(
          icon: Iconsax.people_copy,
          title: AppStrings.following,
          onTap: () => Get.toNamed(AppRoutes.followingScreen),
        ),
         _buildMenuItem(
          icon: Iconsax.user_add_copy,
          title: AppStrings.astrologerRegistration,
          onTap: () => Get.to(() => const AstrologerRegistrationScreen()),
        ),

        const SizedBox(height: 10),
        _buildSectionHeader(AppStrings.supportLegal),
        _buildMenuItem(
          icon: Iconsax.headphone_copy,
          title: AppStrings.customerSupport,
          onTap: () => Get.to(() => const HelpSupportScreen()),
        ),
        _buildMenuItem(
          icon: Iconsax.message_question_copy,
          title: AppStrings.faq,
          onTap: () => Get.toNamed(AppRoutes.faq),
        ),
        _buildMenuItem(
          icon: Iconsax.shield_tick_copy,
          title: AppStrings.privacyPolicyProfile,
          onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
        ),
        _buildMenuItem(
          icon: Iconsax.document_text_copy,
          title: AppStrings.termsAndConditions,
          onTap: () => Get.toNamed(AppRoutes.termsAndConditions),
        ),
         _buildMenuItem(
          icon: Iconsax.money_change_copy,
          title: AppStrings.paymentPolicy,
         onTap: () => Get.toNamed(AppRoutes.paymentPolicy)
         // onTap: () => Get.to(() => SimpleContentScreen(title: AppStrings.paymentPolicy, content: "Refund Policy Content Placeholder...")),
        ),

        const SizedBox(height: 10),
        _buildSectionHeader(AppStrings.appInfo),
        _buildMenuItem(
          icon: Iconsax.like_1_copy,
          title: AppStrings.feedback,
          onTap: () => Get.to(() => const FeedbackScreen()),
        ),
        _buildMenuItem(
          icon: Iconsax.star_1_copy,
          title: AppStrings.rateUs,
          onTap: () => _rateUs(),
        ),
         _buildMenuItem(
          icon: Iconsax.share_copy,
          title: AppStrings.share,
          onTap: () => _shareApp(),
        ),
        _buildMenuItem(
          icon: Iconsax.info_circle_copy,
          title: AppStrings.aboutUs,
          onTap: () => Get.to(() => SimpleContentScreen(title: AppStrings.aboutUs, content: "About Us Content Placeholder...")),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AppText(
          title,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.lightPink.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.deepPink, size: 20),
      ),
      title: AppText(
        title,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF2E1A47),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black26),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      minVerticalPadding: 15,
    );
  }

  Widget _buildActionButtons(AuthController authController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Logout Button
          OutlinedButton(
            onPressed: () {
              Get.dialog(
                Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.logout_rounded, color: Colors.red, size: 32),
                        ),
                        const SizedBox(height: 20),
                        const AppText(
                          'Logout',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E1A47),
                        ),
                        const SizedBox(height: 12),
                        AppText(
                          'Are you sure you want to logout from your account?',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(color: Colors.grey[300]!),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: AppText('Cancel', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                  authController.logout();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: Colors.red,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const AppText('Logout', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.red.withOpacity(0.05),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                AppText(
                  'Log Out',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 15),

          TextButton(
            onPressed: () => authController.deleteAccount(),
            child: const AppText(
              'Delete Account',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),

        ],
      ),
    );
  }

  void _rateUs() async {
    final Uri url = Uri.parse('https://play.google.com/store/apps/details?id=com.astro.user');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch Play Store');
    }
  }

  void _shareApp() {
    Share.share(
      'Download ${AppConstants.appName} app for accurate astrology predictions and consultations: https://play.google.com/store/apps/details?id=com.astro.user',
    );
  }
}
