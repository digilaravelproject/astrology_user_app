import 'package:astro_user/core/theme/app_colors.dart';
import 'package:astro_user/core/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import '../../live/presentation/pages/live_room_screen.dart';
import 'package:get/get.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../dashboard/bindings/dashboard_binding.dart';
import '../../live/presentation/controllers/live_controller.dart';
import '../../../core/constants/app_urls.dart';

class LiveSessionSection extends StatelessWidget {
  const LiveSessionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F9), // Light pinkish background like the image
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Banner
          _buildHighFidelityHeader(),
          
          const SizedBox(height: 24),
          
          // 2. Main CTA Card (Red with Gold Button)
          _buildMainCtaCard(context),
          
          const SizedBox(height: 24),
          
          // 3. Astrologer High-Fidelity Card (Nebula/Moon)
          _buildAstrologerNebulaCard(context),
          
          const SizedBox(height: 20),
          
          // 4. Footer Benefits
          _buildFooterBenefits(),
        ],
      ),
    );
  }

  Widget _buildHighFidelityHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${AppStrings.payAmountPrefix} ',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4A1010),
                      ),
                    ),
                    TextSpan(
                      text: '₹50 ',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFD32F2F),
                      ),
                    ),
                    TextSpan(
                      text: '${AppStrings.forLiveSession} ',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4A1010),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${AppStrings.attendAskQuestionsWith} ',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4A1010),
                      ),
                    ),
                    TextSpan(
                      text: '${AppStrings.anyAstrologerTill30Min}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4A1010),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
             // Glow effect
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD32F2F).withOpacity(0.15),
                    const Color(0xFFD32F2F).withOpacity(0),
                  ],
                ),
              ),
            ),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: const DecorationImage(
                  image: NetworkImage('https://www.varanasiastro.com/uploads/1/4/4/1/14411482/400534819.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainCtaCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.2,
          colors: [
            Color(0xFFE53935), // Vibrant Red
            Color(0xFF8B0000), // Dark Deep Red
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B0000).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Stardust Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/stardust.png',
                repeat: ImageRepeat.repeat,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              children: [
                AppText(
                  '${AppStrings.payAmountPrefix} ₹50 ${AppStrings.forLiveSession}',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                const SizedBox(height: 16),
                // Golden Pill Button
                GestureDetector(
                  onTap: () {
                    if (Get.isRegistered<LiveController>()) {
                      Get.find<LiveController>().fetchActiveSessions();
                    }
                    Get.offAll(
                      () => const DashboardScreen(), 
                      arguments: {'index': 4, 'skip_promo': true},
                      binding: DashboardBinding(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: AppText(
                      AppStrings.joinLiveSession,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF8B0000),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppText(
                  "${AppStrings.askUnlimitedQuestions30Min1} ${AppStrings.askUnlimitedQuestions30Min2}",
                  textAlign: TextAlign.center,
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildIconLabel(Icons.star, 'Select Any Expert Astrologer'),
                    _buildIconLabel(Icons.flash_on, 'Instant Live Replies'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconLabel(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFFFD54F), size: 12),
        const SizedBox(width: 4),
        AppText(
          text,
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  Widget _buildAstrologerNebulaCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        image: const DecorationImage(
          image: AssetImage('assets/images/bg_join_session_home.jpeg'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // White Overlay for Readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white.withOpacity(0.5), // Adjust opacity as needed
              ),
            ),
          ),
          // Background Moon/Sparkle elements
          Positioned(
            top: 15,
            left: 20,
            child: Opacity(
              opacity: 0.3,
              child: Icon(Icons.shield_moon_outlined, color: Colors.white, size: 40),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/stardust.png',
                repeat: ImageRepeat.repeat,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Obx(() {
                  final liveController = Get.find<LiveController>();
                  final activeSessions = liveController.activeSessions;
                  
                  if (activeSessions.isEmpty) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          'No astrologers currently live',
                          fontSize: 12,
                          color: AppColors.deepPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    );
                  }
                  
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: activeSessions.take(4).map((session) {
                      final imageUrl = (session.astrologer?.profilePhoto != null && session.astrologer!.profilePhoto!.isNotEmpty)
                          ? (session.astrologer!.profilePhoto!.startsWith('http')
                              ? session.astrologer!.profilePhoto!
                              : '${AppUrls.baseImageUrl}${session.astrologer!.profilePhoto}')
                          : 'https://theblunttimes.in/wp-content/uploads/2024/02/astro-1.jpg';
                      
                      return _buildAstroPfp(
                        session.astrologer?.name ?? 'Astrologer', 
                        '${session.viewerCount}', 
                        '?', 
                        imageUrl,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LiveRoomScreen(
                                sessionId: session.id,
                                astrologerName: session.astrologer?.name ?? 'Astrologer',
                                astrologerImage: session.astrologer?.profilePhoto ?? '',
                              ),
                            ),
                          );
                        }
                      );
                    }).toList(),
                  );
                }),


              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAstroPfp(String name, String viewers, String badgeType, String imageUrl, VoidCallback onTap) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Positioned(
                bottom: -8,
                child:
                // badgeType == 'star'
                    // ? Container(
                    //     padding: const EdgeInsets.all(4),
                    //     decoration: const BoxDecoration(
                    //       color: Colors.white,
                    //       shape: BoxShape.circle,
                    //       boxShadow: [
                    //         BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                    //       ],
                    //     ),
                    //     child: const Icon(Icons.star, color: Color(0xFFFFB300), size: 16),
                    //   )
                    // :
                Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/bubble_img.png',
                            width: 35,
                            height: 35,
                          ),
                          Positioned(
                            top: 6, // Adjusted to fit inside the bubble image
                            child: const Icon(Icons.question_mark_rounded, color: Color(0xFFD32F2F), size: 14),
                          ),
                        ],
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppText(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.deepPink,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) => const Icon(Icons.star, color: Color(0xFFFFB300), size: 9)),
          ),
          AppText(
            '($viewers watching)',
            fontSize: 8,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildFooterBenefits() {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: AppStrings.askUnlimitedQuestions30Min1,

                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepPink,
                ),
              ),
              TextSpan(
                text: " ${AppStrings.askUnlimitedQuestions30Min2}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.deepPink
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        _buildBenefitItem('Select Any Expert Astrologer'),
        const SizedBox(height: 5),
        _buildBenefitItem('Instant Live Replies'),
      ],
    );
  }

  Widget _buildBenefitItem(String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: AppColors.deepPink,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 12),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: AppText(
            text,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4A1010),
          ),
        ),
      ],
    );
  }
}
