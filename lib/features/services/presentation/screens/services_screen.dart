import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:astro_user/core/widgets/custom_image_widget.dart';
import 'package:astro_user/core/widgets/coming_soon_screen.dart';
import 'package:astro_user/core/constants/app_strings.dart';
import 'package:astro_user/core/widgets/app_text.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        gradient: RadialGradient(
          center: const Alignment(0.8, -0.6),
          radius: 1.5,
          colors: [
            const Color(0xFFFFECE1).withValues(alpha: 0.6),
            const Color(0xFFF9F9FB),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildSection(AppStrings.latestOfferings, isNew: true),
              _buildHorizontalMasonry([
                _ServiceData(AppStrings.bhriguMargdarshan, "https://img.freepik.com/free-vector/astrology-concept-illustration_114360-1014.jpg", Colors.orange.shade50),
                _ServiceData(AppStrings.palmScanAI, "https://img.freepik.com/free-vector/hand-palm-lines-astrology-concept_23-2148630043.jpg", Colors.blue.shade50),
                _ServiceData(AppStrings.chineseHoroscope, "https://img.freepik.com/free-vector/chinese-zodiac-concept-illustration_114360-18456.jpg", Colors.red.shade50),
                _ServiceData(AppStrings.yearlyMap2024, "https://img.freepik.com/free-vector/astrology-concept-illustration_114360-1014.jpg", Colors.purple.shade50),
              ]),
              
              _buildSection("Vedic Astrology"),
              _buildModernGrid([
                _ServiceData(AppStrings.kundali, "https://img.freepik.com/free-vector/zodiac-wheel-with-astrology-icons_23-2148425232.jpg", Colors.purple.shade50),
                _ServiceData(AppStrings.matchMakingService, "https://img.freepik.com/free-vector/love-story-concept-illustration_114360-1558.jpg", Colors.pink.shade50),
                _ServiceData(AppStrings.dailyPanchangService, "https://img.freepik.com/free-vector/calendar-concept-illustration_114360-1234.jpg", Colors.orange.shade50),
                _ServiceData(AppStrings.varshphal, "https://img.freepik.com/free-vector/astrology-concept-illustration_114360-1014.jpg", Colors.blue.shade50),
                _ServiceData(AppStrings.transitChart, "https://img.freepik.com/free-vector/astrology-concept-illustration_114360-1014.jpg", Colors.indigo.shade50),
                _ServiceData(AppStrings.rajyoga, "https://img.freepik.com/free-vector/royal-crown-concept-illustration_114360-1234.jpg", Colors.amber.shade50),
                _ServiceData(AppStrings.dasha, "https://img.freepik.com/free-vector/constellation-concept-illustration_114360-1555.jpg", Colors.teal.shade50),
                _ServiceData(AppStrings.hora, "https://img.freepik.com/free-vector/clock-concept-illustration_114360-1234.jpg", Colors.cyan.shade50),
                _ServiceData(AppStrings.sadeSati, "https://img.freepik.com/free-vector/planet-concept-illustration_114360-1555.jpg", Colors.deepPurple.shade50),
                _ServiceData(AppStrings.mangalDosh, "https://img.freepik.com/free-vector/mars-planet-concept-illustration_114360-1555.jpg", Colors.red.shade50),
              ]),

              _buildSection("Cosmic & Spiritual"),
              _buildModernGrid([
                _ServiceData(AppStrings.numerology, "https://img.freepik.com/free-vector/numbers-concept-illustration_114360-1234.jpg", Colors.green.shade50),
                _ServiceData(AppStrings.tarotReading, "https://img.freepik.com/free-vector/tarot-cards-concept-illustration_114360-1555.jpg", Colors.purple.shade50),
                _ServiceData(AppStrings.palmistry, "https://img.freepik.com/free-vector/hand-palm-lines-astrology-concept_23-2148630043.jpg", Colors.orange.shade50),
                _ServiceData(AppStrings.lalKitab, "https://img.freepik.com/free-vector/book-concept-illustration_114360-1234.jpg", Colors.red.shade50),
                _ServiceData(AppStrings.vastu, "https://img.freepik.com/free-vector/house-concept-illustration_114360-1234.jpg", Colors.brown.shade50),
                _ServiceData(AppStrings.kpChart, "https://img.freepik.com/free-vector/constellation-concept-illustration_114360-1555.jpg", Colors.blueGrey.shade50),
                _ServiceData(AppStrings.gemstonesService, "https://img.freepik.com/free-vector/diamond-concept-illustration_114360-1234.jpg", Colors.blue.shade50),
                _ServiceData(AppStrings.rudraksha, "https://img.freepik.com/free-vector/mandalas-concept-illustration_114360-1555.jpg", Colors.brown.shade50),
                _ServiceData(AppStrings.babyNames, "https://img.freepik.com/free-vector/baby-concept-illustration_114360-1234.jpg", Colors.pink.shade50),
                _ServiceData(AppStrings.shubhMuhurat, "https://img.freepik.com/free-vector/clock-concept-illustration_114360-1234.jpg", Colors.amber.shade50),
              ]),
              
              const SizedBox(height: 280),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                AppStrings.explore,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2E1A47).withValues(alpha: 0.6),
              ),
              AppText(
                AppStrings.ourServices,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2E1A47),
                height: 1.1,
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.apps_rounded, color: AppColors.primaryColor, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, {bool isNew = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
      child: Row(
        children: [
          AppText(
            title == AppStrings.latestOfferings ? AppStrings.latestOfferings : (title == "Vedic Astrology" ? AppStrings.vedicAstrology : (title == "Cosmic & Spiritual" ? AppStrings.cosmicSpiritual : title)),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2E1A47),
            letterSpacing: -0.5,
          ),
          if (isNew) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppText(
                AppStrings.newTag,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF4CAF50),
                letterSpacing: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHorizontalMasonry(List<_ServiceData> items) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ComingSoonScreen(title: item.title))),
            child: Container(
              width: 260,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Opacity(
                      opacity: 0.8,
                      child: CustomImageWidget(
                        imagePath: item.imageUrl,
                        width: 130,
                        height: 130,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          item.title.replaceAll(' ', '\n'),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2E1A47).withValues(alpha: 0.9),
                          height: 1.2,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_right_alt_rounded, color: Color(0xFF2E1A47)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernGrid(List<_ServiceData> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 1.5,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ComingSoonScreen(title: item.title))),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF0F0F0), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Opacity(
                      opacity: 0.6,
                      child: CustomImageWidget(
                        imagePath: item.imageUrl,
                        width: 50,
                        height: 50,
                        radius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: AppText(
                      item.title,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E1A47).withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ServiceData {
  final String title;
  final String imageUrl;
  final Color color;

  _ServiceData(this.title, this.imageUrl, this.color);
}
