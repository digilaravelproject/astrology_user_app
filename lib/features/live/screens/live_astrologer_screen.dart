import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_image_widget.dart';
import '../../../core/widgets/coming_soon_screen.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'live_room_screen.dart';

class LiveAstrologerScreen extends StatelessWidget {
  const LiveAstrologerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> liveSessions = [
      {
        "name": "Astro Joy M",
        "title": "Career & Success",
        "image": "https://randomuser.me/api/portraits/women/44.jpg",
        "viewers": "1.2k"
      },
      {
        "name": "Astro Anjali",
        "title": "Relationship Guide",
        "image": "https://randomuser.me/api/portraits/women/68.jpg",
        "viewers": "850"
      },
      {
        "name": "Astro Kavi",
        "title": "Daily Predictions",
        "image": "https://randomuser.me/api/portraits/women/33.jpg",
        "viewers": "2.1k"
      },
      {
        "name": "Astro Meera",
        "title": "Tarot Reading",
        "image": "https://randomuser.me/api/portraits/women/90.jpg",
        "viewers": "540"
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.liveSessionsTitle,
        showLeading: false,
        actions: [
          _buildActionItem(Icons.search_rounded, () => Navigator.push(context, MaterialPageRoute(builder: (_) => ComingSoonScreen(title: AppStrings.search)))),
          _buildActionItem(Icons.tune_rounded, () => Navigator.push(context, MaterialPageRoute(builder: (_) => ComingSoonScreen(title: AppStrings.filters)))),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLiveBanner(),
            _buildSectionTitle(),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: 0.78,
              ),
              itemCount: liveSessions.length,
              itemBuilder: (context, index) {
                final session = liveSessions[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LiveRoomScreen(
                        astrologerName: session["name"]!,
                        astrologerImage: session["image"]!,
                      ),
                    ),
                  ),
                  child: _buildLiveCard(session),
                );
              },
            ),
            const SizedBox(height: 280),
          ],
        ),
      ),
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

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF2E1A47), size: 22),
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
            color: AppColors.primaryColor.withValues(alpha: 0.3),
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
                child: Icon(Icons.live_tv_rounded, size: 140, color: Colors.white),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
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
                      color: Colors.red.withValues(alpha: 0.4),
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
          AppText(
            AppStrings.seeAll,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCard(Map<String, String> session) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
              imagePath: session["image"]!,
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
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.4, 0.9],
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    )
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.visibility_rounded, color: Colors.white, size: 12),
                    const SizedBox(width: 5),
                    AppText(
                      session["viewers"]!,
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
                    session["name"]!,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    session["title"]!,
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
