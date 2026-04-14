import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../constants/app_strings.dart';
import 'app_text.dart';
import 'custom_image_widget.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/wallet/screens/wallet_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/bindings/profile_binding.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/notification/screens/notification_screen.dart'; // Assuming chat history might be here or similar

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Drawer Header
          _buildDrawerHeader(authController),
          
          // Drawer Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildDrawerItem(Icons.shopping_bag_outlined, AppStrings.myOrders),
                _buildDrawerItem(
                  Icons.account_balance_wallet_outlined,
                  AppStrings.walletTransactions,
                  onTap: () {
                    Get.back();
                    Get.to(() => const WalletScreen());
                  },
                ),
                _buildDrawerItem(
                  Icons.person_outline,
                  AppStrings.myProfileNav,
                  onTap: () {
                    Get.back();
                    Get.to(() => const ProfileScreen(), binding: ProfileBinding());
                  },
                ),
                _buildDrawerItem(
                  Icons.chat_bubble_outline,
                  AppStrings.chatHistory,
                  onTap: () {
                    Get.back();
                    Get.to(() => const HistoryScreen());
                  },
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Divider(color: Colors.grey.shade200, thickness: 1),
                ),

                _buildDrawerItem(Icons.settings_outlined, AppStrings.settings),
                _buildDrawerItem(Icons.star_outline, AppStrings.rateUs),
                _buildDrawerItem(Icons.share_outlined, AppStrings.shareApp),
                _buildDrawerItem(Icons.help_outline, AppStrings.helpSupport),
              ],
            ),
          ),
          
          // Logout Section
          Padding(
            padding: const EdgeInsets.all(24),
            child: InkWell(
              onTap: () {
                Get.back(); // Close drawer
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
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD1D1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.logout, color: Color(0xFFD32F2F), size: 18),
                    ),
                    const SizedBox(width: 16),
                    AppText(
                      AppStrings.logOut,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD32F2F),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(AuthController authController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E1A47), // Deep Purple
            AppColors.deepPink, // Pink
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: CustomImageWidget(
                imagePath: 'https://i.pravatar.cc/150?u=a042581f4e29026704d', // Placeholder or user image
                height: 70,
                width: 70,
                radius: BorderRadius.circular(35),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => AppText(
            authController.currentUser.value?.name ?? AppStrings.guest,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
          )),
          const SizedBox(height: 4),
          Obx(() => AppText(
            authController.currentUser.value?.mobile ?? "+91 XXXXX XXXXX",
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.8),
          )),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.lightPink.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.deepPink, size: 22),
      ),
      title: AppText(
        title,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2E1A47),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
