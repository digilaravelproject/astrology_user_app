import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/session_bottom_sheet_helper.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/cosmic_background.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_rating_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/widgets/custom_image_widget.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../astrologers/controllers/astrologer_controller.dart';
import '../../../astrologers/screens/astrologer_detail_screen.dart';
import '../../../astrologers/domain/models/astrologer_model.dart';
import '../../../astrologers/bindings/astrologers_binding.dart';
import '../../../astrologers/screens/astrologer_search_screen.dart';
import 'package:astro_user/routes/route_helper.dart';
import '../../../notification/controllers/notification_controller.dart';
import 'chat_screen.dart';
import '../../../../core/utils/wallet_helper.dart';
import '../../../wallet/controllers/wallet_controller.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final astrologerController = Get.find<AstrologerController>();
    
    // Fetch top astrologers for stories and all astrologers for the filtered list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      astrologerController.fetchTopAstrologers(serviceType: 'chat');
      astrologerController.fetchFilteredAstrologers(type: 'all', serviceType: 'chat');
    });
    
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Chat with Astrologers',
        showLeading: false,
        actions: [
          _buildActionItem(Icons.notifications_outlined, () {}),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await astrologerController.fetchTopAstrologers(serviceType: 'chat');
          await astrologerController.fetchFilteredAstrologers(type: 'all', serviceType: 'chat');
        },
        child: CustomScrollView(
            slivers: [
              // Search Bar
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: GestureDetector(
                    onTap: () => Get.to(() => const AstrologerSearchScreen(serviceType: 'chat')),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey.shade600, size: 22),
                          const SizedBox(width: 12),
                          AppText(
                            'Search astrologers...',
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // White Container with Content
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Astrologers Heading
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFB74D),
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            const AppText(
                              'Top Astrologers',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D2D2D),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        height: 120,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Obx(() {
                          if (astrologerController.isTopLoading.value) {
                            return _buildTopShimmerList();
                          }
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: astrologerController.topAstrologers.length,
                            itemBuilder: (context, index) {
                              return _buildStoryItem(astrologerController.topAstrologers[index]);
                            },
                          );
                        }),
                      ),

                      // Filter Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Obx(() {
                          // Access reactive properties directly to ensure GetX registers the dependency
                          final _ = astrologerController.selectedSkills.length;
                          final isOnlineOnly = astrologerController.isOnlineOnly.value;
                          
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                const SizedBox(width: 18),
                                // All Chip
                                _buildInteractiveChip(
                                  label: 'All', 
                                  isSelected: astrologerController.selectedSkills.isEmpty && !isOnlineOnly,
                                  onTap: () => astrologerController.fetchFilteredAstrologers(type: 'all', serviceType: 'chat'),
                                ),
                                const SizedBox(width: 8),

                                // Dynamic Skill Chips
                                ...AppConstants.skillList.map((skill) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildInteractiveChip(
                                    label: skill, 
                                    isSelected: astrologerController.selectedSkills.contains(skill),
                                    onTap: () => astrologerController.toggleSkill(skill, serviceType: 'chat'),
                                  ),
                                )),

                                // Online Chip
                                _buildInteractiveChip(
                                  label: 'Online', 
                                  isSelected: isOnlineOnly,
                                  onTap: () => astrologerController.fetchFilteredAstrologers(serviceType: 'chat', online: !isOnlineOnly),
                                ),
                                const SizedBox(width: 18),
                              ],
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Astrologer Cards List (REACTIVE SECTION)
              Obx(() {
                if (astrologerController.isFilteredLoading.value) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: _buildShimmerList(),
                  );
                }

                final astrologers = astrologerController.filteredAstrologers;
                if (astrologers.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: AppText('No astrologers available', color: Colors.grey),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildAstrologerCard(context, astrologers[index]);
                      },
                      childCount: astrologers.length,
                    ),
                  ),
                );
              }),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
    );
  }

  Widget _buildStoryItem(AstrologerModel astro) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => AstrologerDetailScreen(astrologerId: astro.id),
          binding: AstrologersBinding(),
          transition: Transition.rightToLeft,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.goldAccent,
                      width: 1.5,
                    ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: astro.profilePhoto != null && astro.profilePhoto!.isNotEmpty
                        ? CustomImageWidget(
                            imagePath: astro.fullProfilePhoto,
                            fit: BoxFit.cover,
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: astro.isAvailableOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 65,
              child: AppText(
                astro.name,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.lightPink,
      child: const Icon(
        Icons.person,
        color: AppColors.primaryColor,
        size: 36,
      ),
    );
  }

  Widget _buildPlaceholderLarge() {
    return Container(
      color: AppColors.lightPink,
      child: const Icon(
        Icons.person,
        color: AppColors.primaryColor,
        size: 50,
      ),
    );
  }

  Widget _buildActionItem(IconData icon, VoidCallback onTap) {
    final notificationController = Get.find<NotificationController>();
    bool isNotification = icon == Icons.notifications_outlined;
    
    Widget iconWidget = Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.lightPink.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: const Color(0xFF2E1A47), size: 20),
    );

    if (isNotification) {
      return GestureDetector(
        onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            iconWidget,
            Obx(() {
              final count = notificationController.unreadCount.value;
              if (count <= 0) return const SizedBox.shrink();
              return Positioned(
                right: -2,
                top: -2,
                child: _buildBadgeWidget(count),
              );
            }),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: iconWidget,
    );
  }

  Widget _buildBadgeWidget(int count) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.deepPink,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        print('--- CHIP TAPPED: $label ---');
        onTap();
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            print('--- INKWELL TAPPED: $label ---');
            onTap();
          },
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.primaryColor.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                colors: [AppColors.primaryColor, AppColors.accentColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
                  : null,
              color: isSelected ? null : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey.shade300,
                width: 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ] : null,
            ),
            child: AppText(
              label,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAstrologerCard(BuildContext context, AstrologerModel astro) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => AstrologerDetailScreen(astrologerId: astro.id),
          binding: AstrologersBinding(),
          transition: Transition.rightToLeft,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.deepPink.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepPink.withOpacity(0.08),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Profile Image
                Stack(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.goldAccent,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: astro.profilePhoto != null && astro.profilePhoto!.isNotEmpty
                            ? CustomImageWidget(
                                imagePath: astro.fullProfilePhoto,
                                fit: BoxFit.cover,
                              )
                            : _buildPlaceholderLarge(),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: astro.isAvailableOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Static Rating as requested
                CustomRatingBar(
                  rating: astro.rating,
                  size: 15,
                ),
                const SizedBox(width: 12),
                AppText(
                  '${astro.totalOrders > 0 ? astro.totalOrders : (astro.id * 15 + 100)}k+ ${AppStrings.ordersLabel}',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepPink.withOpacity(0.7),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Name
                  Row(
                    children: [
                      AppText(
                        astro.name,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 4),
                      // Static verified icon as requested
                      const Icon(
                        Icons.verified,
                        color: Colors.green,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Skills
                  AppText(
                    astro.areasOfExpertise.join(', '),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Languages
                  AppText(
                    astro.languages.join(', '),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Experience
                  AppText(
                    '${AppStrings.expLabelPrefix} ${astro.yearsOfExperience} ${AppStrings.years}',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 8),
                  // Chat Button
                  !astro.isAvailableOnline
                      ? Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Astrologer is offline.",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomButton(
                              text: 'Session (1 hr 45 min) @ ₹500',
                              icon: Icons.timer,
                              fontSize: 11,
                              height: 32,
                              borderRadius: 8,
                              backgroundColor: Colors.orange,
                              textColor: Colors.white,
                              borderColor: Colors.orange,
                              onTap: () {
                                SessionBottomSheetHelper.show(context, astro);
                              },
                            ),
                            if (astro.isChatEnabled) ...[
                              const SizedBox(height: 8),
                              CustomButton(
                                text: '${AppStrings.chat} - ₹${astro.chatRate ?? '0'}/min',
                                icon: Icons.chat,
                                fontSize: 11,
                                height: 32,
                                borderRadius: 8,
                                backgroundColor: Colors.transparent,
                                textColor: const Color(0xFF4CAF50),
                                borderColor: const Color(0xFF4CAF50),
                                onTap: () {
                                        final walletController = Get.find<WalletController>();
                                        final double balance = double.tryParse(walletController.balance) ?? 0.0;
                                        WalletHelper.checkBalanceAndProceed(
                                        context: context,
                                        type: 'chat',
                                        name: astro.name,
                                        imageUrl: astro.fullProfilePhoto,
                                        price: astro.chatRate ?? '0',
                                        providerId: astro.userId,
                                        simulatedBalance: balance,
                                      );
                                },
                              ),
                            ],
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopShimmerList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 50,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
        childCount: 5,
      ),
    );
  }
}
