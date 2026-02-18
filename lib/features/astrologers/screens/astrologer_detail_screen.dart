import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_rating_bar.dart';
import '../../chat/screens/chat_screen.dart';
import '../../call/screens/call_screen.dart';
import '../../../core/utils/wallet_helper.dart';

class AstrologerDetailScreen extends StatelessWidget {
  final String name;
  final String skills;
  final String languages;
  final String experience;
  final double rating;
  final String price;
  final String discountPrice;
  final String orders;
  final String minutes;
  final String imageUrl;
  final String bio;
  final bool isRisingStar;
  final bool isVerified;

  const AstrologerDetailScreen({
    Key? key,
    required this.name,
    required this.skills,
    required this.languages,
    required this.experience,
    required this.rating,
    required this.price,
    required this.discountPrice,
    required this.orders,
    required this.minutes,
    required this.imageUrl,
    required this.bio,
    this.isRisingStar = false,
    this.isVerified = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Color(0xFF2D2D2D)),
                onSelected: (value) {
                  // Handle menu selection
                  if (value == 'Block') {
                    _showBlockBottomSheet(context);
                  } else if (value == 'Report') {
                     _showReportBottomSheet(context);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return {'Block', 'Report'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: AppText(
                        choice,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColorPrimary,
                      ),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Card - EXACT MATCH
                _buildProfileHeaderCard(),
                const SizedBox(height: 16),
                // Gallery Section
                _buildGallerySection(),
                const SizedBox(height: 16),
                // Reviews Section
                _buildReviewsSection(),
                const SizedBox(height: 16),
                // Chat with Assistant
                _buildChatAssistantSection(),
                const SizedBox(height: 16),
                // Send Gift
                _buildGiftSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  void _showBlockBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.block_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              AppText(
                "Block $name?",
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              const SizedBox(height: 8),
              AppText(
                "You won't be able to message or call this astrologer anymore.",
                fontSize: 14,
                color: Colors.grey.shade600,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "Cancel",
                      backgroundColor: Colors.grey.shade100,
                      textColor: Colors.black87,
                      onTap: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: "Block",
                      backgroundColor: Colors.red,
                      onTap: () {
                        Get.back();
                        Get.snackbar(
                          "Blocked",
                          "You have blocked $name",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.black87,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(20),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showReportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true, // Allow full height if needed
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: AppText(
                    "Report Astrologer",
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                 const SizedBox(height: 20),
                 AppText(
                  "Why do you want to report?",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                const SizedBox(height: 12),
                
                ...["Inappropriate Behavior", "Spam", "Fake Profile", "Other"].map((reason) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                         Get.back();
                         Get.snackbar(
                            "Reported",
                            "Thank you for reporting. We will investigate.",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(20),
                          );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(reason, fontSize: 14, color: Colors.black87),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddReviewBottomSheet(BuildContext context) {
    double _selectedRating = 0;
    final TextEditingController _reviewController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: AppText(
                      "Write a Review",
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedRating = index + 1.0;
                            });
                          },
                          icon: Icon(
                            index < _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppText(
                    "Share your experience",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _reviewController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "How was your session with $name?",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: "Submit Review",
                      backgroundColor: AppColors.deepPink,
                      textColor: Colors.white,
                      onTap: () {
                        if (_selectedRating == 0) {
                          Get.snackbar("Error", "Please select a rating",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                             margin: const EdgeInsets.all(20),
                          );
                          return;
                        }
                        Get.back();
                        Get.snackbar(
                          "Success",
                          "Review submitted successfully!",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(20),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildProfileHeaderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.deepPink.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepPink.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with Golden Border
              Column(
                children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFD700),
                          Color(0xFFFFA000),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Rising Star Badge
                  if (isRisingStar)
                    Positioned(
                      top: -4,
                      left: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.deepPink,
                              AppColors.primaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Rising Star',
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomRatingBar(
                  rating: rating,
                  size: 14,
                ),
              ],
            ),
          const SizedBox(width: 12),
          // Details
          Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Flexible(
                                    child: AppText(
                                      name,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textColorPrimary,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isVerified) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.verified,
                                      color: Color(0xFF4CAF50),
                                      size: 16,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              AppText(
                                skills,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textColorSecondary,
                                height: 1.3,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Follow and Menu Group
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 70,
                              height: 28,
                              child: CustomButton(
                                text: 'Follow',
                                fontSize: 10,
                                height: 28,
                                borderRadius: 14,
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      languages,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColorHint,
                    ),
                    const SizedBox(height: 4),
                  Row(
                    children: [
                      AppText(
                        'Exp: $experience',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(width: 8),
                      // Price Information
                      AppText(
                        '₹$price',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColorSecondary,
                        style: GoogleFonts.inter(decoration: TextDecoration.lineThrough),
                      ),
                      const SizedBox(width: 6),
                      AppText(
                        '₹$discountPrice',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.deepPink,
                      ),
                      AppText(
                        '/min',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColorPrimary,
                      ),
                    ],
                  ),
                  ],
                ),
              ),
            ],
          ),


          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.deepPink,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepPink.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.bolt,
                        color: Colors.yellow,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: AppText(
                          '₹ 30/session for 30 minute complete guide',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Divider
          Container(
            height: 1,
            color: const Color(0xFFEEEEEE),
          ),
          const SizedBox(height: 12),
          // Bio Description
          _BioText(bio: bio),
        ],
      ),
    );
  }



  Widget _buildGallerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.photo_library, color: Color(0xFFE91E63), size: 20),
              const SizedBox(width: 8),
              AppText(
                'Gallery',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textColorPrimary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showFullScreenGallery(context, List.generate(3, (index) => imageUrl), index),
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    final reviews = [
      {
        "name": "Dipti",
        "avatar": "https://theblunttimes.in/wp-content/uploads/2024/02/astro-1.jpg",
        "rating": 5.0,
        "review": "veeraji aapa kamal hoo...aur kuch bhi me bata nahi sakati itana achaa experience aata hai muze ki kya bolu.... 🧿🙏👏💐🎉",
        "reply": "😊 Thank you so much dipti ji🫂💗 May god bless you 🌞🙏"
      },
      {
        "name": "Shweta",
        "avatar": "https://theblunttimes.in/wp-content/uploads/2024/02/astro-1.jpg",
        "rating": 5.0,
        "review": "all my questions are always answered very nicely and gave me the best advice and make me feel good",
        "reply": "Thank you so much Shweta mam💗 May god bless you 🌞🙏"
      },
      {
        "name": "Shweta",
        "avatar": "https://theblunttimes.in/wp-content/uploads/2024/02/astro-1.jpg",
        "rating": 5.0,
        "review": "Genius consultant and answered all my questions very nicely, realy good guidance, her k knowledge and skills shows she is doing great in her field.",
        "reply": "Awwww 🥰😌 Thank you so much Shweta mam💗 May god bless you dear and you have all the happiness in the world 🫂💗"
      },
      {
        "name": "Sibangi",
        "avatar": "https://theblunttimes.in/wp-content/uploads/2024/02/astro-1.jpg",
        "rating": 5.0,
        "review": "She is the most sweetest reader I have interacted. It's been a year that after connecting with her I haven't changed my Tarot reader. Her readings are accurate.",
        "reply": null
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviews Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rate_rounded, color: Color(0xFFE91E63), size: 24),
                  const SizedBox(width: 8),
                  AppText(
                    'User Reviews',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepPink,
                  ),
                ],
              ),
              AppText(
                'View All',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textColorSecondary,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Reviews List
          ...reviews.map((review) => _buildReviewCard(review)).toList(),
          
          // See all reviews link
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: AppText(
              'See all reviews',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.deepPink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5), // Light pink background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(review['avatar'] as String),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppText(
                  review['name'] as String,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF880E4F),
                ),
              ),
              const Icon(Icons.more_vert, size: 20, color: Colors.grey),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Rating
          CustomRatingBar(
            rating: (review['rating'] as num).toDouble(),
            size: 16,
          ),
          
          const SizedBox(height: 8),
          
          // Review Text
          AppText(
            review['review'] as String,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF880E4F),
            style: const TextStyle(height: 1.4),
          ),
          
          // Reply Section (if exists)
          if (review['reply'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEbee),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Vera',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A148C),
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    review['reply'] as String,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF4A148C),
                    style: const TextStyle(height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGiftItems() {
    final gifts = [
      {'name': 'Flowers', 'price': '₹ 51', 'icon': '💐'},
      {'name': 'Pooja Thali', 'price': '₹ 51', 'icon': '🍛'},
      {'name': 'Heart', 'price': '₹ 51', 'icon': '❤️'},
      {'name': 'Sweets', 'price': '₹ 101', 'icon': '🍬'},
      {'name': 'Magician', 'price': '₹ 101', 'icon': '🧙‍♂️'},
      {'name': 'Chocolates', 'price': '₹ 101', 'icon': '🍫'},
      {'name': 'Crown', 'price': '₹ 501', 'icon': '👑'},
      {'name': 'Dakshina', 'price': '₹ 2100', 'icon': '💰'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: gifts.length,
      itemBuilder: (context, index) {
        final gift = gifts[index];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 50,
              width: 50,
              alignment: Alignment.center,
              child: AppText(
                gift['icon']!,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 4),
            AppText(
              gift['name']!,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF880E4F),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            AppText(
              gift['price']!,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF880E4F),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => WalletHelper.checkBalanceAndProceed(
                context: context,
                type: 'chat',
                name: name,
                imageUrl: imageUrl,
                price: discountPrice,
                simulatedBalance: 500.0, // Force sufficient balance
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.message_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chat',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '₹$discountPrice/min',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => WalletHelper.checkBalanceAndProceed(
                context: context,
                type: 'call',
                name: name,
                imageUrl: imageUrl,
                price: discountPrice,
                simulatedBalance: 500.0, // Force sufficient balance
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD32F2F).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.call, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Call',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '₹$discountPrice/min',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildChatAssistantSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCDD2)),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.support_agent, color: Color(0xFFE91E63), size: 24),
          const SizedBox(width: 8),
          AppText(
            'Chat with Assistant',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFC2185B),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Color(0xFFE91E63)),
        ],
      ),
    );
  }

  Widget _buildGiftSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.card_giftcard, color: Color(0xFFE91E63), size: 20),
              const SizedBox(width: 8),
              AppText(
                'Send Gift to Vera',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFC2185B),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.info_outline, size: 16, color: Colors.grey),
              const Spacer(),
              AppText(
                '₹ 3',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFC2185B),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGiftItems(),
        ],
      ),
    );
  }

  void _showFullScreenGallery(BuildContext context, List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: PageView.builder(
            itemCount: images.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    images[index],
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

}

class _BioText extends StatefulWidget {
  final String bio;
  const _BioText({Key? key, required this.bio}) : super(key: key);

  @override
  State<_BioText> createState() => _BioTextState();
}

class _BioTextState extends State<_BioText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          widget.bio,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textColorSecondary,
          maxLines: isExpanded ? null : 3,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
          style: const TextStyle(height: 1.6),
        ),
        if (widget.bio.length > 100) ...[ // Simple heuristic to show button
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: AppText(
                isExpanded ? 'Show less' : 'See more',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.deepPink,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
