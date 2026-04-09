import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_image_widget.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_urls.dart';
import '../widgets/animated_zodiac_wheel.dart';
import '../widgets/home_greeting.dart';
import '../widgets/horoscope_pill.dart';
import '../widgets/founder_message_banner.dart';
import '../widgets/remedy_grid.dart';
import '../widgets/service_section_row.dart';
import '../widgets/shop_services_section.dart';
import '../widgets/astrology_blogs_section.dart';
import '../widgets/astrologers_preview_section.dart';
import '../widgets/live_session_section.dart';
import '../../matrimony/widgets/matrimony_section.dart';
import '../widgets/remedy_services_section.dart';
import '../../wallet/screens/wallet_screen.dart';
import '../../notification/screens/notification_screen.dart';
import '../../notification/controllers/notification_controller.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../core/widgets/custom_drawer.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../../notification/controllers/notification_controller.dart';
import '../../astrologers/controllers/astrologer_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../widgets/astrologer_filter_bottom_sheet.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> filters = [AppStrings.homeFilter, AppStrings.homeAll, AppStrings.homeFavourite, AppStrings.homeNew];

  @override
  void initState() {
    super.initState();
    // Refresh profile to get latest photo/data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().refreshProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final walletController = Get.find<WalletController>();






    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const CustomDrawer(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primaryColor,
        child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            elevation: 0,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,

            titleSpacing: 0,

            // Top Bar (Pinned)
            title: Container(

              alignment: Alignment.center,
              child: _buildStickyTopBar(authController, walletController),

            ),


            // Scrollable Content (Scrolls behind pinned headers)
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                color: Colors.white,
              ),
            ),
          ),
          
          // Astrologers List
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildScrollableGreeting(authController),
                  ),
                  const SizedBox(height: 25),
                  const FounderMessageBanner(),
                  const SizedBox(height: 25),
                  const RemedyGrid(),
                  const SizedBox(height: 15),
                  const AstrologyBlogsSection(),
                  const SizedBox(height: 25),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9C27B0).withOpacity(0.1), // Purple tint
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: Color(0xFF9C27B0),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        AppText(
                          AppStrings.talkToAstrologer,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E1A47),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
/*                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => Get.find<AstrologerController>().updateSearch(value),
                        decoration: InputDecoration(
                          hintText: AppStrings.search,
                          hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: AppColors.primaryColor, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),*/
                ],
              )
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _FilterBarDelegate(
              child: Container(
                height: 60,
                alignment: Alignment.center,
                child: _buildFilterBarUI(),
              ),
            ),
          ),
          // Astrologers List
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: const AstrologersPreviewSection(),
            ),
          ),


          SliverToBoxAdapter(
            child: Container(
                child: Column(
                  children: [
                    const SizedBox(height: 35),
                    const LiveSessionSection(),
                    const SizedBox(height: 35),
                    const RemedyServicesSection(),
                    const SizedBox(height: 150),
                  ],
                )
            ),
          ),
          
          // // Remaining content
          // SliverToBoxAdapter(
          //   child: Column(
          //     children: [
          //       const ShopServicesSection(),
          //       const SizedBox(height: 35),
          //       const ServiceSectionRow(),
          //       const SizedBox(height: 35),
          //       const MatrimonySection(),
          //       const SizedBox(height: 40),
          //     ],
          //   ),
          // ),
        ],
      ),
    ),
  );
}

  Future<void> _onRefresh() async {
    await Future.wait([
      Get.find<AuthController>().checkLoginStatus(),
      Get.find<WalletController>().fetchWallet(),
      Get.find<NotificationController>().fetchNotificationCount(),
      Get.find<AstrologerController>().fetchAstrologers(),
    ]);
  }



  Widget _buildStickyTopBar(AuthController authController, WalletController walletController) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.to(() => const ProfileScreen()),
            child: Obx(() {
              final user = authController.currentUser.value;
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomImageWidget(
                  imagePath: (() {
                    final photo = user?.profilePhoto;
                    if (photo == null || photo.isEmpty) return null;
                    if (photo.startsWith('http')) return photo;
                    final cleanPhoto = photo.startsWith('/') ? photo.substring(1) : photo;
                    return '${AppUrls.baseImageUrl}$cleanPhoto';
                  })(),
                  height: 40,
                  width: 40,
                  radius: BorderRadius.circular(20),
                  fallbackWidget: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user?.name.isNotEmpty == true
                            ? user!.name[0].toUpperCase()
                            : 'U',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.wallet),
                child: Obx(() {
                  final bal = walletController.wallet.value?.balance ?? '0.00';
                  return _buildCoinWalletChip(bal);
                }),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Get.to(() => const NotificationScreen()),
                child: Obx(() {
                  final notificationController = Get.find<NotificationController>();
                  final count = notificationController.unreadCount.value;
                  return Badge(
                    label: Text(count.toString()),
                    isLabelVisible: count > 0,
                    backgroundColor: AppColors.deepPink,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_outlined, size: 22, color: Color(0xFF2E1A47)),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBarUI() {
    final controller = Get.find<AstrologerController>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
          children: filters.map((filter) {
            bool isFilter = filter == AppStrings.homeFilter;
            
            // Map filter string to controller type
            String type = 'all';
            if (filter == AppStrings.homeFavourite) type = 'favourite';
            if (filter == AppStrings.homeNew) type = 'new';
            
            bool isSelected = !isFilter && controller.selectedType.value == type;

            return Container(
              padding: EdgeInsets.only(right: 10, left: isFilter ? 12 : 0),
              child: GestureDetector(
                onTap: () {
                  if (isFilter) {
                    _showFilterBottomSheet(context);
                  } else {
                    controller.updateType(type);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isFilter || isSelected
                        ? const LinearGradient(
                            colors: [AppColors.deepPink, Color(0xFFD81B60)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isFilter || isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isFilter || isSelected ? Colors.transparent : AppColors.deepPink.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      if (isFilter || isSelected)
                        BoxShadow(
                          color: AppColors.deepPink.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      else
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isFilter) ...[
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: AppText(
                              '!',
                              color: AppColors.deepPink,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (filter == AppStrings.homeAll) ...[
                        Icon(
                          Icons.apps,
                          color: isSelected ? Colors.white : AppColors.deepPink,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                      ],
                      if (filter == AppStrings.homeFavourite) ...[
                        Icon(
                          Icons.star_outline,
                          color: isSelected ? Colors.white : AppColors.deepPink,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                      ],
                      if (filter == AppStrings.homeNew) ...[
                        Icon(
                          Icons.auto_awesome,
                          color: isSelected ? Colors.white : AppColors.deepPink,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                      ],
                      AppText(
                        filter,
                        color: isFilter || isSelected ? Colors.white : AppColors.deepPink,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        )),
      ),
    );
  }

  Widget _buildScrollableGreeting(AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppText(
              AppStrings.hello,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(width: 8),
            Obx(() => AppText(
              authController.currentUser.value?.name ?? AppStrings.guest,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.deepPink,
              height: 1.1,
              letterSpacing: -0.5,
            )),
            const SizedBox(width: 4),
            const WavingEmoji(),
          ],
        ),

      ],
    );
  }

  Widget _buildCoinWalletChip(String balance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD1D1), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD32F2F).withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFB300), Color(0xFFFFA000)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 10),
          ),
          const SizedBox(width: 6),
          AppText(
            balance,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2E1A47),
            letterSpacing: 0.5,
          ),
        ],
      ),
    );
  }



  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AstrologerFilterBottomSheet(),
    );
  }
}
class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _FilterBarDelegate({required this.child});

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: 60,
      child: Container(
        color: Colors.white,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(_FilterBarDelegate oldDelegate) => true;
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
