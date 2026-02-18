import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/cosmic_background.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_rating_bar.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/constants/app_strings.dart';
import 'call_screen.dart';

class CallListScreen extends StatelessWidget {
  const CallListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> astrologers = [
      {
        "name": "Pratishtha",
        "skills": "Vedic, Numerology, Tarot",
        "languages": "English, Hindi",
        "experience": "4 Years",
        "rating": 5.0,
        "orders": "10k+",
        "price": "299",
        "image": "https://news4masses.com/wp-content/uploads/2017/12/Sohini-Sastri-kolkata-list1-web.jpg",
        "isOnline": true,
        "isVerified": true,
      },
      {
        "name": "Vera",
        "skills": "Tarot, Psychic, Life Coach",
        "languages": "Marathi, English, Hindi",
        "experience": "4 Years",
        "rating": 5.0,
        "orders": "5k+",
        "price": "349",
        "image": "https://www.varanasiastro.com/uploads/1/4/4/1/14411482/400534819.jpg",
        "isOnline": true,
        "isVerified": true,
      },
      {
        "name": "Siyukti",
        "skills": "Numerology, Tarot, Life Coach",
        "languages": "Marathi, Hindi",
        "experience": "14 Years",
        "rating": 5.0,
        "orders": "10k+",
        "price": "299",
        "image": "https://news4masses.com/wp-content/uploads/2017/09/panditji-bhambi-best-astrologers-in-india.jpg",
        "isOnline": false,
        "isVerified": false,
      },
      {
        "name": "Rajan",
        "skills": "Vedic",
        "languages": "English, Hindi, Sanskrit",
        "experience": "12 Years",
        "rating": 4.9,
        "orders": "8k+",
        "price": "399",
        "image": "https://theblunttimes.in/wp-content/uploads/2024/02/astro-1.jpg",
        "isOnline": true,
        "isVerified": true,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Call Astrologers',
        showLeading: false,
        actions: [
          _buildActionItem(Icons.notifications_outlined, () {}),
          const SizedBox(width: 12),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Search Bar
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey.shade600, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search astrologers...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          filled: false,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // White Container with Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
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
                          color: Color(0xFFFFB74D),
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        const AppText(
                          'Top Astrologers',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D2D2D),
                        ),
                      ],
                    ),
                  ),

                  // Story-like Astrologer Section
                  Container(
                    height: 120,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: astrologers.length,
                      itemBuilder: (context, index) {
                        return _buildStoryItem(astrologers[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Filter Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const SizedBox(width: 18),
                          _buildFilterChip('All', true),
                          const SizedBox(width: 8),
                          _buildFilterChip('Vedic', false),
                          const SizedBox(width: 8),
                          _buildFilterChip('Tarot', false),
                          const SizedBox(width: 8),
                          _buildFilterChip('Numerology', false),
                          const SizedBox(width: 8),
                          _buildFilterChip('Life Coach', false),
                          const SizedBox(width: 8),
                          _buildFilterChip('Online', false),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          
          // Astrologer Cards List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildAstrologerCard(context, astrologers[index]);
                },
                childCount: astrologers.length,
              ),
            ),
          ),
          
          SliverToBoxAdapter(child: const SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildStoryItem(Map<String, dynamic> astro) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 65,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: astro['isOnline'] == true
                  ? const LinearGradient(
                colors: [AppColors.primaryColor, AppColors.accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              border: Border.all(
                color: astro['isOnline'] == true
                    ? Colors.transparent
                    : Colors.green.shade300,
                width: 2.2,
              ),
            ),
            // padding: const EdgeInsets.all(0.5),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 0.2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  astro['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.lightPink,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.primaryColor,
                        size: 36,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 65,
            child: AppText(
              astro['name'],
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
    );
  }

  Widget _buildActionItem(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.lightPink.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF2E1A47), size: 20),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [AppColors.primaryColor, AppColors.accentColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isSelected ? null : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.deepPink : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: AppText(
        label,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isSelected ? Colors.white : Colors.grey.shade700,
      ),
    );
  }

  Widget _buildAstrologerCard(BuildContext context, Map<String, dynamic> astro) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.deepPink.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepPink.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Profile Image
              Stack(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.goldAccent,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        astro['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.lightPink,
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primaryColor,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (astro['isOnline'] == true)
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
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
              const SizedBox(height: 12),
              // Rating and Orders
              CustomRatingBar(
                rating: (astro['rating'] as num).toDouble(),
                size: 15,
              ),
              const SizedBox(width: 12),
              AppText(
                '${astro['orders']} ${AppStrings.ordersLabel}',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.deepPink.withOpacity(0.7),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Name
                Row(
                  children: [
                    AppText(
                      astro['name'],
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 4),
                    if (astro['isVerified'] == true)
                      const Icon(
                        Icons.verified,
                        color: Colors.green,
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                // Skills
                AppText(
                  astro['skills'],
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.deepPink.withOpacity(0.8),
                ),
                // Languages
                AppText(
                  astro['languages'],
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.deepPink.withOpacity(0.8),
                ),
                // Experience
                AppText(
                  '${AppStrings.expLabelPrefix} ${astro['experience']}',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.deepPink.withOpacity(0.8),
                ),
                const SizedBox(height: 8),
                // Call Button
                CustomButton(
                  text: '${AppStrings.call} - ₹${astro['price']}/min',
                  icon: Icons.call,
                  fontSize: 11,
                  height: 32,
                  borderRadius: 8,
                  onTap: astro['isOnline'] == true
                      ? () {
                          Get.to(() => CallScreen(
                                astrologerName: astro['name'],
                                astrologerImage: astro['image'],
                              ));
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
