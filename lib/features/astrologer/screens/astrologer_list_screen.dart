import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_image_widget.dart';
import '../../../core/widgets/coming_soon_screen.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';

class AstrologerListScreen extends StatelessWidget {
  const AstrologerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> astrologers = [
      {
        "name": "Astro Joy M",
        "exp": "12 Years",
        "price": "35/min",
        "image": "https://randomuser.me/api/portraits/men/32.jpg",
        "rating": "4.8",
        "status": "Online",
        "languages": "Hindi, English",
        "waitTime": "2 min"
      },
      {
        "name": "Astro Anjali",
        "exp": "8 Years",
        "price": "25/min",
        "image": "https://randomuser.me/api/portraits/women/44.jpg",
        "rating": "4.9",
        "status": "Busy",
        "languages": "Hindi, Punjabi",
        "waitTime": "10 min"
      },
      {
        "name": "Astro Kavi",
        "exp": "15 Years",
        "price": "45/min",
        "image": "https://randomuser.me/api/portraits/men/85.jpg",
        "rating": "4.7",
        "status": "Online",
        "languages": "English, Sanskrit",
        "waitTime": "5 min"
      },
      {
        "name": "Astro Meera",
        "exp": "6 Years",
        "price": "20/min",
        "image": "https://randomuser.me/api/portraits/women/65.jpg",
        "rating": "4.5",
        "status": "Online",
        "languages": "Hindi, Gujarati",
        "waitTime": "Available"
      },
      {
        "name": "Astro Rahul",
        "exp": "10 Years",
        "price": "30/min",
        "image": "https://randomuser.me/api/portraits/men/22.jpg",
        "rating": "4.6",
        "status": "Busy",
        "languages": "Hindi, Marathi",
        "waitTime": "15 min"
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        gradient: RadialGradient(
          center: const Alignment(-0.8, -0.6),
          radius: 1.2,
          colors: [
            const Color(0xFFFFF4E1).withValues(alpha: 0.6),
            const Color(0xFFF9F9FB),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context),
              _buildFilterChips(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Column(
                  children: astrologers.map((astro) => _buildAstrologerCard(context, astro)).toList(),
                ),
              ),
              const SizedBox(height: 280),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                AppStrings.talkTo,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2E1A47).withValues(alpha: 0.6),
              ),
              AppText(
                AppStrings.experts,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2E1A47),
                height: 1.1,
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComingSoonScreen(title: "Search"))),
                child: _buildIconButton(Icons.search_rounded),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComingSoonScreen(title: "Filters"))),
                child: _buildIconButton(Icons.tune_rounded),
              ),
            ],
          ),
        ],
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

  Widget _buildFilterChips() {
    final filters = ["All", "Vedic", "Tarot", "Palmistry", "Numerology", "Vastu"];
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return Container(
            margin: const EdgeInsets.only(right: 12, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [AppColors.primaryColor, AppColors.secondaryColor],
                    )
                  : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      )
                    ],
              border: isSelected ? null : Border.all(color: const Color(0xFFEEEEEE)),
            ),
            alignment: Alignment.center,
            child: AppText(
              filters[index] == "All" ? AppStrings.all : filters[index],
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF2E1A47).withValues(alpha: 0.7),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAstrologerCard(BuildContext context, Map<String, dynamic> astro) {
    final bool isOnline = astro["status"] == "Online";

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isOnline ? const Color(0xFF4CAF50).withValues(alpha: 0.5) : Colors.orange.withValues(alpha: 0.5), 
                        width: 2.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: CustomImageWidget(
                          imagePath: astro["image"]!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 5,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isOnline ? const Color(0xFF4CAF50) : Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: (isOnline ? const Color(0xFF4CAF50) : Colors.orange).withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 14),
                    const SizedBox(width: 3),
                    AppText(
                      astro["rating"]!,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E1A47),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: AppText(
                        astro["name"]!,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2E1A47),
                        letterSpacing: -0.2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded, color: Color(0xFF2196F3), size: 16),
                  ],
                ),
                const SizedBox(height: 3),
                AppText(
                  "Vedic, Vastu, Tarot",
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: [
                    _buildTinyTag(Icons.history_rounded, astro["exp"]!, Colors.blueGrey.shade400),
                    _buildTinyTag(Icons.translate_rounded, "Hin, Eng", Colors.blueGrey.shade400),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText(
                      "₹${astro["price"].split('/')[0]}",
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryColor,
                    ),
                    AppText(
                      "/${AppStrings.min}",
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComingSoonScreen(title: "Chat Coming Soon"))),
                child: _buildActionButton(Icons.chat_bubble_rounded, AppStrings.chat, AppColors.primaryColor),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComingSoonScreen(title: "Call Coming Soon"))),
                child: _buildActionButton(Icons.call_rounded, AppStrings.call, const Color(0xFF4CAF50)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTinyTag(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        AppText(
          label,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Container(
      width: 62,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 3),
          AppText(
            label,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ],
      ),
    );
  }
}
