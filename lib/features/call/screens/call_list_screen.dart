import 'package:astro_user/core/utils/custom_snackbar.dart';
import '../../home/widgets/astrologer_action_buttons.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/cosmic_background.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_rating_bar.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/constants/app_urls.dart';
import '../../../core/constants/image_constants.dart';
import '../../../core/widgets/custom_image_widget.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../../astrologers/controllers/astrologer_controller.dart';
import '../../astrologers/domain/models/astrologer_model.dart';
import '../../astrologers/screens/astrologer_detail_screen.dart';
import '../../home/widgets/astrologers_preview_section.dart';
import '../../../core/utils/session_bottom_sheet_helper.dart';
import '../../astrologers/bindings/astrologers_binding.dart';
import '../../astrologers/screens/astrologer_search_screen.dart';
import 'package:astro_user/routes/route_helper.dart';
import '../../notification/controllers/notification_controller.dart';
import 'call_screen.dart';
import '../../../core/utils/wallet_helper.dart';
import '../../wallet/controllers/wallet_controller.dart';

class CallListScreen extends StatelessWidget {
  const CallListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final astrologerController = Get.find<AstrologerController>();
    
    // Fetch top astrologers for stories and all astrologers for the filtered list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      astrologerController.fetchTopAstrologers(serviceType: 'call');
      astrologerController.fetchFilteredAstrologers(type: 'all', serviceType: 'call');
    });

    final TextEditingController searchController = TextEditingController();

    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.25,
            child: Image.asset(
              ImageConstants.loginBackground,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context, serviceType: 'call'),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await astrologerController.fetchTopAstrologers(serviceType: 'call');
                      await astrologerController.fetchFilteredAstrologers(type: 'all', serviceType: 'call');
                    },
                    child: CustomScrollView(
                      slivers: [


              // White Container with Content
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
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
                              color: AppColors.primaryColor,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            const AppText(
                              'Top Astrologers',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
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
                                  label: 'All'.tr, 
                                  isSelected: astrologerController.selectedSkills.isEmpty && !isOnlineOnly,
                                  onTap: () => astrologerController.fetchFilteredAstrologers(type: 'all', serviceType: 'call'),
                                ),
                                const SizedBox(width: 8),

                                // Dynamic Skill Chips
                                ...AppConstants.skillList.map((skill) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildInteractiveChip(
                                    label: skill.tr, 
                                    isSelected: astrologerController.selectedSkills.contains(skill),
                                    onTap: () => astrologerController.toggleSkill(skill, serviceType: 'call'),
                                  ),
                                )),

                                // Online Chip
                                _buildInteractiveChip(
                                  label: 'Online'.tr, 
                                  isSelected: isOnlineOnly,
                                  onTap: () => astrologerController.fetchFilteredAstrologers(serviceType: 'call', online: !isOnlineOnly),
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

            const SliverToBoxAdapter(child: SizedBox(height: 150)),
          ],
        ),
      ),
        )
      ],)
          )
        )
      ]
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
                      color: astro.statusColor,
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
        print('--- CHIP TAPPED ($label) ---');
        onTap();
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            print('--- INKWELL TAPPED ($label) ---');
            onTap();
          },
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.primaryColor.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor : Colors.white,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column (Profile & Rating)
                Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: astro.isAvailableOnline ? Colors.green : Colors.grey.shade300,
                              width: 2,
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
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: astro.statusColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7E6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFFB74D), size: 12),
                          const SizedBox(width: 2),
                          AppText(
                            astro.rating.toStringAsFixed(1),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Middle Column (Details)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppText(
                            astro.name,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E1A47),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Colors.blue, size: 14),
                        ],
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        astro.areasOfExpertise.map((e) => e.trim().tr).join(', '),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.schedule, color: Colors.grey, size: 12),
                          const SizedBox(width: 2),
                          AppText(
                            '${astro.yearsOfExperience} ${"Years".tr}',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.language, color: Colors.grey, size: 12),
                          const SizedBox(width: 2),
                          Expanded(
                            child: AppText(
                              astro.languages.map((l) => l.trim().tr).join(', '),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          AppText(
                            '₹${astro.callRate ?? '0'}',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryColor,
                          ),
                          AppText(
                            '/${"min".tr}',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                          if (astro.packageSessionPriceOnly != null) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: AppText(
                                '${"Session".tr} ${astro.packageSessionPriceOnly}',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (astro.isCallEnabled == true) ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CustomButton(
                        text: astro.packageSessionTimeOnly,
                        icon: Icons.timer,
                        fontSize: 11,
                        height: 32,
                        borderRadius: 8,
                        backgroundColor: (!astro.isOnline || astro.isBusy) ? Colors.grey.withOpacity(0.2) : (astro.isPurchase == true ? Colors.green : Colors.orange),
                        textColor: (!astro.isOnline || astro.isBusy) ? Colors.grey : Colors.white,
                        borderColor: (!astro.isOnline || astro.isBusy) ? Colors.grey : (astro.isPurchase == true ? Colors.green : Colors.orange),
                        onTap: () {
                          if (!astro.isOnline || astro.isBusy) {
                            CustomSnackbar.showInfo(astro.isBusy ? 'Astrologer is currently engaged.' : 'Astrologer is offline.');
                            return;
                          }
                          SessionBottomSheetHelper.show(context, astro);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: AstrologerActionButtons(
                    astro: astro,
                    isDetailStyle: false,
                    showChat: false,
                    showCall: true,
                  ),
                ),
              ],
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


  Widget _buildHeader(BuildContext context, {required String serviceType}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Talk to Experts
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Talk to',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
              AppText(
                'Experts',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2E1A47),
              ),
            ],
          ),
          // Right Side: Action Icons
          Row(
            children: [
              _buildHeaderIcon(Icons.search, () {
                Get.to(() => AstrologerSearchScreen(serviceType: serviceType));
              }),

            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF2E1A47), size: 22),
      ),
    );
  }
}
