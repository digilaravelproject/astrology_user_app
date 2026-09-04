import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:astro_user/core/constants/app_strings.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:astro_user/core/widgets/custom_image_widget.dart';
import 'package:astro_user/features/auth/presentation/controllers/auth_controller.dart';
import 'package:astro_user/routes/app_routes.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/services/fcm_notification_service.dart';
import 'package:astro_user/features/home/presentation/widgets/animated_zodiac_wheel.dart';
import 'package:astro_user/features/home/presentation/widgets/home_greeting.dart';
import 'package:astro_user/features/home/presentation/widgets/horoscope_pill.dart';
import 'package:astro_user/features/home/presentation/widgets/founder_message_banner.dart';
import 'package:astro_user/features/home/presentation/widgets/remedy_grid.dart';
import 'package:astro_user/features/home/presentation/widgets/service_section_row.dart';
import 'package:astro_user/features/home/presentation/widgets/shop_services_section.dart';
import 'package:astro_user/features/home/presentation/widgets/astrology_blogs_section.dart';
import 'package:astro_user/features/home/presentation/widgets/astrologers_preview_section.dart';
import 'package:astro_user/features/home/presentation/widgets/live_session_section.dart';
import 'package:astro_user/features/matrimony/presentation/widgets/matrimony_section.dart';
import 'package:astro_user/features/home/presentation/widgets/remedy_services_section.dart';
import 'package:astro_user/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:astro_user/features/notification/presentation/screens/notification_screen.dart';
import 'package:astro_user/features/call/presentation/controllers/call_controller.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/services/websocket/websocket_service.dart';
import 'package:astro_user/core/services/local_notification_service.dart';
import 'package:astro_user/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_user/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_user/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_user/features/notification/presentation/controllers/notification_controller.dart';
import 'package:astro_user/features/profile/presentation/screens/profile_screen.dart';
import 'package:astro_user/core/widgets/custom_drawer.dart';
import 'package:astro_user/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:astro_user/features/notification/presentation/controllers/notification_controller.dart';
import 'package:astro_user/features/astrologers/presentation/controllers/astrologer_controller.dart';
import 'package:astro_user/features/profile/presentation/controllers/profile_controller.dart';
import 'package:astro_user/features/profile/presentation/bindings/profile_binding.dart';
import 'package:astro_user/features/home/presentation/widgets/astrologer_filter_bottom_sheet.dart';
import 'package:astro_user/features/live/presentation/controllers/live_controller.dart';
import 'package:astro_user/features/home/presentation/controllers/blog_controller.dart';
import 'package:astro_user/features/home/presentation/controllers/remedy_controller.dart';
import 'package:astro_user/features/home/presentation/controllers/founder_controller.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  List<String> get filters => [AppStrings.homeFilter, AppStrings.homeAll, AppStrings.homeFavourite, AppStrings.homeNew];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
        if (Get.isRegistered<AstrologerController>()) {
          Get.find<AstrologerController>().loadMoreAstrologers();
        }
      }
    });

    // Refresh profile to get latest photo/data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() async {
        try {
          FCMNotificationService.registerDeviceToken(null);
          if (Get.isRegistered<ProfileController>()) {
            Get.find<ProfileController>().refreshProfile();
          }
          if (Get.isRegistered<LiveController>()) {
            Get.find<LiveController>().fetchActiveSessions();
          }
        } catch (_) {}
      });
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
            pinned: false,
            floating: false,
            elevation: 0,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            toolbarHeight: 145,

            titleSpacing: 0,

            // Top Bar (Pinned)
            title: Container(

              alignment: Alignment.center,
              child: _buildStickyTopBar(authController, walletController),

            ),


            // Scrollable Content (Scrolls behind pinned headers)
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    color: const Color(0xFFFFF7F2), // Light peach background
                  ),
                  const AnimatedZodiacWheel(),
                ],
              ),
            ),
          ),
          
          // Astrologers List
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  const FounderMessageBanner(),
                  Obx(() {
                    try {
                      final remedyController = Get.find<RemedyController>();
                      if (remedyController.remedies.isEmpty && !remedyController.isLoading.value) {
                        return const SizedBox.shrink();
                      }
                    } catch (_) {}
                    return const Column(
                      children: [
                        SizedBox(height: 25),
                        RemedyGrid(),
                      ],
                    );
                  }),
                  Obx(() {
                    try {
                      final blogController = Get.find<BlogController>();
                      if (blogController.blogs.isEmpty && !blogController.isLoading.value) {
                        return const SizedBox.shrink();
                      }
                    } catch (_) {}
                    return const Column(
                      children: [
                        SizedBox(height: 15),
                        AstrologyBlogsSection(),
                        SizedBox(height: 25),
                      ],
                    );
                  }),
                  // Old Search Bar and chat row removed
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
            child: Obx(() {
              final liveController = Get.isRegistered<LiveController>() ? Get.find<LiveController>() : null;
              final hasActiveSessions = liveController != null && liveController.activeSessions.isNotEmpty;
              return Column(
                children: [
                  if (hasActiveSessions) const SizedBox(height: 35),
               //   const LiveSessionSection(),
                  const SizedBox(height: 130),
                ],
              );
            }),
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
    final List<Future> refreshTasks = [
      Get.find<AuthController>().checkLoginStatus(),
      Get.find<WalletController>().fetchWallet(),
      Get.find<NotificationController>().fetchNotificationCount(),
      Get.find<AstrologerController>().fetchAstrologers(isRefresh: true),
    ];
    
    try {
      refreshTasks.add(Get.find<ProfileController>().refreshProfile());
    } catch (_) {}
    
    try {
      refreshTasks.add(Get.find<BlogController>().fetchBlogs());
    } catch (_) {}
    
    try {
      refreshTasks.add(Get.find<RemedyController>().fetchRemedies());
    } catch (_) {}
    
    try {
      refreshTasks.add(Get.find<FounderController>().fetchFounderWords());
    } catch (_) {}
    
    // Trigger session checks in background so UI refresh isn't blocked by timeout
    try {
      _checkCurrentActiveSession();
    } catch (_) {}

    try {
      if (Get.isRegistered<CallController>()) {
        Get.find<CallController>().checkCurrentActiveCallSession();
      }
    } catch (_) {}

    await Future.wait(refreshTasks);
  }

  Future<void> _checkCurrentActiveSession() async {
    try {
      final response = await Get.find<ApiClient>().get(AppUrls.getCurrentSession);
      if (response.isSuccess && response.body != null) {
        final data = response.body;
        final session = (data is Map)
            ? (data['session'] ?? data['data']?['session'] ?? data['data'] ?? data)
            : null;
        final sessionId = session?['id'];
        final status = session?['status'];
        final startedAt = session?['started_at'] ?? session?['accepted_at'] ?? session?['created_at'];
        final name = session?['provider']?['name'] ?? 'Astrologer';

        if (sessionId != null && startedAt != null) {
          WebSocketService.sessionStartTimes[sessionId] = startedAt.toString();
        }

        DateTime? parsedStart;
        if (startedAt != null) {
          String isoUtc = startedAt.toString().replaceAll(' ', 'T');
          if (!isoUtc.endsWith('Z') && !isoUtc.contains('+') && !isoUtc.contains('-')) {
            isoUtc += 'Z';
          }
          parsedStart = DateTime.tryParse(isoUtc)?.toLocal();
        }
        final int? startedAtMillis = parsedStart?.millisecondsSinceEpoch;

        if (status == 'ongoing' || status == 'initiated' || status == 'accepted') {
          if (sessionId != null) {
            LocalNotificationService.showOngoingChatNotification(
              sessionId: sessionId,
              title: '$name • Chat',
              body: 'Ongoing chat session',
              startedAtMillis: startedAtMillis,
            );
          }
          FloatingChatBubble.show(
            context: Get.context!,
            sessionId: sessionId,
            name: name,
            imageUrl: '',
            status: status,
            startedAt: startedAt,
            onTap: () {
              final currentStatus = FloatingChatBubble.chatStatus.value;
              Get.to(
                () => ChatScreen(
                  astrologerName: name,
                  astrologerImage: '',
                  sessionId: sessionId,
                  initialStatus: currentStatus,
                ),
                binding: ChatBinding(),
              );
            },
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking active chat session on refresh: $e');
    }
  }



  Widget _buildStickyTopBar(AuthController authController, WalletController walletController) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // TOP ROW: Wallet, Notification, Profile
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
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
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2)),
                            ],
                          ),
                          child: const Icon(Icons.notifications_none_rounded, size: 20, color: Color(0xFF2E1A47)),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => Get.to(() => const ProfileScreen(), binding: ProfileBinding()),
                    child: Obx(() {
                      final user = authController.currentUser.value;
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2)),
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
                ],
              ),
            ],
          ),
         // const SizedBox(height: 12),
          // Greeting and Name
          Row(
            children: [
              AppText('Hello'.tr,
                fontSize: 16,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 4),
              const WavingEmoji(),
            ],
          ),
          const SizedBox(height: 8),
          // Expanded(
          //   child:
            Obx(() => Text(
              authController.currentUser.value?.name ?? AppStrings.guest,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF6A0C22), // Dark burgundy color
                letterSpacing: -0.5,
              ),
            )
            ),
         // ),
          // Obx(() => AppText(
          //   authController.currentUser.value?.name ?? AppStrings.guest,
          //   fontSize: 22,
          //   fontWeight: FontWeight.w900,
          //   color: const Color(0xFF8B0000), // Dark red as in image
          //   letterSpacing: -0.5,
          // )),
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
                            colors: [AppColors.primaryColor, AppColors.deepPink],
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
                            child: AppText('!'.tr,
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
