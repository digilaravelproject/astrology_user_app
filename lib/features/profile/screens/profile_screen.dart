import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../wallet/screens/wallet_screen.dart';
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
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: NetworkImage('https://i.pravatar.cc/300?u=a042581f4e29026704d'),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: AppColors.deepPink.withOpacity(0.2), width: 1),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(() => const EditProfileScreen()),
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
          AppText(
            authController.currentUser.value?.mobile ?? "+91 9876543210",
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, AuthController authController) {
    return Column(
      children: [
        _buildSectionHeader(AppStrings.accountSettings),
        _buildMenuItem(
          icon: Icons.translate_rounded,
          title: AppStrings.changeLanguage,
          onTap: () => Get.to(() => const ChangeLanguageScreen()),
        ),
        _buildMenuItem(
          icon: Iconsax.user_copy,
          title: AppStrings.myAccount,
          onTap: () => Get.to(() => const EditProfileScreen()),
        ),
        _buildMenuItem(
          icon: Iconsax.wallet_3_copy,
          title: AppStrings.wallet,
          onTap: () => Get.to(() => const WalletScreen()),
        ),
        _buildMenuItem(
          icon: Iconsax.crown_1_copy,
          title: AppStrings.manageSubscription,
          onTap: () => Get.to(() => const SubscriptionScreen()),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: AppText(AppStrings.proBadge, fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber[800]),
          ),
        ),
        _buildMenuItem(
          icon: Iconsax.arrow_circle_up_copy,
          title: AppStrings.upgradePlan,
          onTap: () => Get.to(() => const SubscriptionScreen()),
        ),
        
        const SizedBox(height: 10),
        _buildSectionHeader(AppStrings.referralsCommunity),
        _buildMenuItem(
          icon: Iconsax.gift_copy,
          title: AppStrings.referAndEarn,
          onTap: () => Get.to(() => const ReferralScreen()),
        ),
        _buildMenuItem(
          icon: Iconsax.people_copy,
          title: AppStrings.following,
          onTap: () => Get.to(() => const FollowingScreen()),
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
          onTap: () => Get.to(() => const FaqScreen()),
        ),
        _buildMenuItem(
          icon: Iconsax.shield_tick_copy,
          title: AppStrings.privacyPolicyProfile,
          onTap: () => Get.to(() => SimpleContentScreen(title: AppStrings.privacyPolicyProfile, content: "Privacy Policy Content Placeholder...")),
        ),
        _buildMenuItem(
          icon: Iconsax.document_text_copy,
          title: AppStrings.termsAndConditions,
          onTap: () => Get.to(() => SimpleContentScreen(title: AppStrings.termsAndConditions, content: "Terms & Conditions Content Placeholder...")),
        ),
         _buildMenuItem(
          icon: Iconsax.money_change_copy,
          title: AppStrings.refundPolicy,
          onTap: () => Get.to(() => SimpleContentScreen(title: AppStrings.refundPolicy, content: "Refund Policy Content Placeholder...")),
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
          onTap: () {},
        ),
         _buildMenuItem(
          icon: Iconsax.share_copy,
          title: AppStrings.share,
          onTap: () {},
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
            onPressed: () => authController.logout(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.errorColor),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: AppColors.errorColor.withOpacity(0.05),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout_rounded, color: AppColors.errorColor, size: 20),
                const SizedBox(width: 8),
                AppText(
                  AppStrings.logOut,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.errorColor,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 15),

          // Delete Account Button (Text Button to be less prominent but visible)
          TextButton(
            onPressed: () {
              // Add delete account logic
              Get.defaultDialog(
                title: AppStrings.deleteAccountTitle,
                middleText: AppStrings.deleteAccountConfirmation,
                textConfirm: AppStrings.delete,
                textCancel: AppStrings.cancel,
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                cancelTextColor: Colors.black,
                onConfirm: () {
                   Get.back();
                   authController.logout(); // Navigate to login for now
                }
              );
            },
            child: AppText(
              AppStrings.deleteAccount,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
