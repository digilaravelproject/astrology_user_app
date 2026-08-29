import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_image_widget.dart';
import '../../../../core/widgets/coming_soon_screen.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../controllers/live_controller.dart';
import '../../data/models/live_session_model.dart';
import 'live_room_screen.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/constants/image_constants.dart';

class LiveAstrologerScreen extends StatefulWidget {
  const LiveAstrologerScreen({super.key});

  @override
  State<LiveAstrologerScreen> createState() => _LiveAstrologerScreenState();
}

class _LiveAstrologerScreenState extends State<LiveAstrologerScreen> {
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10, left: 20, right: 16, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Join'.tr,
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF2D3142),
            letterSpacing: -0.5,
          ),
          const SizedBox(width: 4),
          AppText(
            'Live Sessions',
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF2D3142),
            letterSpacing: -0.5,
          ),
        ],
      ),
    );
  }

  late LiveController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<LiveController>();
    _controller.fetchActiveSessions();
  }

  @override
  Widget build(BuildContext context) {
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
            child: RefreshIndicator(
              onRefresh: () => _controller.fetchActiveSessions(),
              color: AppColors.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    _buildLiveBanner(),
                    _buildSectionTitle(),

                    Obx(() {
                      if (_controller.isLoadingSessions.value) {
                        return const SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        );
                      }

                      if (_controller.activeSessions.isEmpty) {
                        return SizedBox(
                          height: 250,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.video_camera_back_outlined,
                                  size: 48,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 12),
                                AppText(
                                  'No active streams currently.',
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 18,
                              crossAxisSpacing: 18,
                              childAspectRatio: 0.78,
                            ),
                        itemCount: _controller.activeSessions.length,
                        itemBuilder: (context, index) {
                          final session = _controller.activeSessions[index];
                          return GestureDetector(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => LiveRoomScreen(
                                          sessionId: session.id,
                                          astrologerName:
                                              session.astrologer?.name ??
                                              'Astrologer',
                                          astrologerImage:
                                              session
                                                  .astrologer
                                                  ?.profilePhoto ??
                                              '',
                                        ),
                                  ),
                                ),
                            child: _buildLiveCard(session),
                          );
                        },
                      );
                    }),
                    const SizedBox(height: 280),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF2E1A47)),
      ),
    );
  }

  Widget _buildLiveBanner() {
    return Container(
      width: double.infinity,
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.secondaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Opacity(
              opacity: 0.2,
              child: Transform.rotate(
                angle: -0.2,
                child: const Icon(
                  Icons.live_tv_rounded,
                  size: 140,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, color: Colors.white, size: 8),
                      const SizedBox(width: 6),
                      AppText(
                        AppStrings.premiumAccess,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppText(
                  AppStrings.interactiveLivePredictions,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.2,
                ),
                const SizedBox(height: 6),
                AppText(
                  AppStrings.getAnswersInstantlyFromExperts,
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AppText(
                AppStrings.liveNow,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E1A47),
                letterSpacing: 0.5,
              ),
            ],
          ),
          // AppText(
          //   AppStrings.seeAll,
          //   fontSize: 12,
          //   fontWeight: FontWeight.w700,
          //   color: AppColors.primaryColor,
          // ),
        ],
      ),
    );
  }

  Widget _buildLiveCard(LiveSessionModel session) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            CustomImageWidget(
              imagePath:
                  (session.astrologer?.profilePhoto != null &&
                          session.astrologer!.profilePhoto!.isNotEmpty)
                      ? (session.astrologer!.profilePhoto!.startsWith('http')
                          ? session.astrologer!.profilePhoto!
                          : '${AppUrls.baseImageUrl}${session.astrologer!.profilePhoto}')
                      : '',
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.4, 0.9],
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.white, size: 8),
                    const SizedBox(width: 6),
                    AppText(
                      AppStrings.liveBadge,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.visibility_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 5),
                    AppText(
                      '${session.viewerCount}',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 15,
              left: 15,
              right: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    session.astrologer?.name ?? 'Priya Sharma',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    session.title,
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
