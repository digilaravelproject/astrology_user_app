import 'package:astro_user/core/theme/app_colors.dart';
import 'package:astro_user/core/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import '../../live/presentation/pages/live_room_screen.dart';
import 'package:get/get.dart';
import '../../live/presentation/controllers/live_controller.dart';
import '../../../core/constants/app_urls.dart';

class LiveSessionSection extends StatelessWidget {
  const LiveSessionSection({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<LiveController>()) {
        Get.find<LiveController>().fetchActiveSessions();
      }
    });

    return Obx(() {
      if (!Get.isRegistered<LiveController>()) {
        return const SizedBox.shrink();
      }
      final liveController = Get.find<LiveController>();
      if (liveController.activeSessions.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        color: Colors.white,
        child: Stack(
          children: [
            // Background Curved Green Section
            ClipPath(
              clipper: _WaveClipper(),
              child: Container(
                height: 180,
                width: double.infinity,
                color: AppColors.primaryColor,
              ),
            ),

            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                AppText(
                  'Live Consultations',
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      'Top Astrologer',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF8BC34A), // Lime green
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Horizontal list of avatars
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: liveController.activeSessions.length,
                    itemBuilder: (context, index) {
                      final session = liveController.activeSessions[index];
                      final imageUrl =
                          (session.astrologer?.profilePhoto != null &&
                                  session.astrologer!.profilePhoto!.isNotEmpty)
                              ? (session.astrologer!.profilePhoto!.startsWith(
                                    'http',
                                  )
                                  ? session.astrologer!.profilePhoto!
                                  : '${AppUrls.baseImageUrl}${session.astrologer!.profilePhoto}')
                              : 'https://theblunttimes.in/wp-content/uploads/2024/02/astro-1.jpg';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => LiveRoomScreen(
                                      sessionId: session.id,
                                      astrologerName:
                                          session.astrologer?.name ??
                                          'Astrologer',
                                      astrologerImage:
                                          session.astrologer?.profilePhoto ??
                                          '',
                                    ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CustomImageWidget(
                                  imagePath: imageUrl,
                                  height: 75,
                                  width: 75,
                                  radius: BorderRadius.circular(37.5),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 12),
                              AppText(
                                session.astrologer?.name ?? 'Astrologer',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2E1A47),
                              ),
                              const SizedBox(height: 2),
                              AppText(
                                'Vedic Astrologer',
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);

    // Create a gentle wave
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 20);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(
      size.width - (size.width / 4),
      size.height - 40,
    );
    var secondEndPoint = Offset(size.width, size.height - 10);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
