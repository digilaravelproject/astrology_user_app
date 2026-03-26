import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../astrologers/screens/astrologer_detail_screen.dart';
import '../../astrologers/bindings/astrologers_binding.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_rating_bar.dart';
import '../../../core/utils/wallet_helper.dart';

class AstrologersPreviewSection extends StatefulWidget {
  const AstrologersPreviewSection({Key? key}) : super(key: key);

  @override
  State<AstrologersPreviewSection> createState() => _AstrologersPreviewSectionState();
}

class _AstrologersPreviewSectionState extends State<AstrologersPreviewSection> {
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
      "hasOffer": true,
      "offerText": "Feedback",
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
      "hasOffer": false,
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
      "isOnline": true,
      "hasOffer": false,
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
      "hasOffer": false,
      "isVerified": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Astrologers List
        ...astrologers.map((astro) => _buildAstrologerCard(astro)).toList(),
      ],
    );
  }

  Widget _buildAstrologerCard(Map<String, dynamic> astro) {
    return GestureDetector(
      onTap: () {
        /*Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AstrologerDetailScreen(
              name: astro['name'],
              skills: astro['skills'],
              languages: astro['languages'],
              experience: astro['experience'],
              rating: (astro['rating'] as num).toDouble(),
              price: (int.parse(astro['price']) + 100).toString(), // Mock original price
              discountPrice: astro['price'],
              orders: astro['orders'],
              minutes: "120", // Mock data
              imageUrl: astro['image'],
              bio: "Expert in ${astro['skills']} with over ${astro['experience']} of experience. Helping people find their path.",
              isRisingStar: astro['rating'] >= 4.5,
              isVerified: true,
            ),
          ),
        );*/
      },
      child: Container(
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
      child: Stack(
        children: [

          // Online Status (top-right corner)


          Row(
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
              SizedBox(width: 10),
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

                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryColor,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: AppColors.primaryColor,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: AppText(
                              '₹${astro['price']}/min • 30 min session',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Action Buttons (Right side)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 70,
                          height: 30,
                          child: CustomButton(
                            text: AppStrings.call,
                            icon: Icons.call,
                            fontSize: 12,
                            borderRadius: 8,
                            onTap: () => WalletHelper.checkBalanceAndProceed(
                              context: context,
                              type: 'call',
                              name: astro['name'],
                              imageUrl: astro['image'],
                              price: astro['price'],
                              simulatedBalance: 10.0, // Force insufficient balance
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 70,
                          height: 30,
                          child: CustomButton(
                            text: AppStrings.chat,
                            icon: Icons.chat,
                            fontSize: 12,
                            borderRadius: 8,
                            onTap: () => WalletHelper.checkBalanceAndProceed(
                              context: context,
                              type: 'chat',
                              name: astro['name'],
                              imageUrl: astro['image'],
                              price: astro['price'],
                              simulatedBalance: 10.0, // Force insufficient balance
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Container(
          //
          //   height: 20,
          //   decoration: BoxDecoration(
          //       color: AppColors.softPink,
          //       borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
          //   ),
          // )


        ],
      ),
    ));
  }

}