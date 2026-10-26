import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:astro_user/features/home/presentation/widgets/astrologers_preview_section.dart';
import 'astrologer_detail_screen.dart';

class AstrologersListScreen extends StatelessWidget {
  const AstrologersListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AppText('Astrologers'.tr,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: const Color(0xFFEC407A).withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5D4037)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _buildAstrologerCard(
              context,
              "Acharya Prakash",
              "Vedic Astrology, Kundli, Career",
              "Vedic Astrology, Love, Marriage",
              "1.2k",
              4.8,
              "50",
              "https://randomuser.me/api/portraits/men/32.jpg",
            ),
            _buildAstrologerCard(
              context,
              "Guru Aditya",
              "Vedic Astrology, Love, Marriage",
              "Vedic Astrology, Love, Marriage",
              "1.1k",
              4.7,
              "45",
              "https://randomuser.me/api/portraits/men/45.jpg",
            ),
            _buildAstrologerCard(
              context,
              "Astrologer Riya",
              "Tarot Reading, Numerology, Career",
              "Tarot Reading, Numerology, Career",
              "950",
              4.6,
              "40",
              "https://randomuser.me/api/portraits/women/65.jpg",
            ),
            _buildAstrologerCard(
              context,
              "Astrologer Sanjay",
              "Vedic Astrology, Kundli, Health",
              "Vedic Astrology, Kundli, Health",
              "970",
              4.5,
              "35",
              "https://randomuser.me/api/portraits/men/52.jpg",
            ),
            _buildAstrologerCard(
              context,
              "Pandit Mukesh",
              "Vedic Astrology, Love, Vastu",
              "Vedic Astrology, Love, Vastu",
              "750",
              4.4,
              "30",
              "https://randomuser.me/api/portraits/men/68.jpg",
            ),
            _buildAstrologerCard(
              context,
              "Astrologer Sneha",
              "Tarot Reading, Numerology, Love",
              "Tarot Reading, Numerology, Love",
              "600",
              4.3,
              "25",
              "https://randomuser.me/api/portraits/women/44.jpg",
            ),
            _buildAstrologerCard(
              context,
              "Acharya Rohit",
              "Vedic Astrology, Finance, Career",
              "Vedic Astrology, Finance, Career",
              "500",
              4.2,
              "20",
              "https://randomuser.me/api/portraits/men/75.jpg",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAstrologerCard(
    BuildContext context,
    String name,
    String primarySkills,
    String secondarySkills,
    String reviews,
    double rating,
    String price,
    String imageUrl,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder:
        //         (context) => AstrologerDetailScreen(
        //           name: name,
        //           skills: primarySkills,
        //           languages: 'English, Hindi, Marathi',
        //           experience: '4 Years',
        //           rating: rating,
        //           price: '50',
        //           discountPrice: price,
        //           orders: reviews,
        //           minutes: '100k+',
        //           imageUrl: imageUrl,
        //           bio:
        //               '$name is a $primarySkills expert in India. She loves to help her clients when they are in need. Her readings are spirit-guided and she works according to Astrology ethics to bring stability in the lives of the people. However, her main motive is to give you clarity and insight regarding your life and also to empower you with the spiritual knowledge of different energies that are revolving around us.',
        //           isRisingStar: rating >= 4.7,
        //         ),
        //   ),
        // );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFCE4EC), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC407A).withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar with online badge
            Stack(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF48FB1), Color(0xFFEC407A)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEC407A).withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2.5),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // Details section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2D2D2D),
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFFB74D),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Color(0xFFFFB74D),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toString(),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFF8F00),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 13,
                        color: Color(0xFFEC407A),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          primarySkills,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5D4037),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 11,
                        color: Color(0xFF9E9E9E),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$reviews consultations",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Call button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFEF5350), Color(0xFFD32F2F)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD32F2F).withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText('Reset'.tr, // This seems like a placeholder, keeping as per instruction
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                      Text(
                        // Keeping this as Text because the instruction only showed it as context, not a replacement
                        price,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text("/min".tr,
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.call, size: 10, color: Colors.white),
                        const SizedBox(width: 3),
                      ],
                    ),
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
