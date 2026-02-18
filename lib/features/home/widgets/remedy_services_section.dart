import 'package:astro_user/core/theme/app_colors.dart';
import 'package:astro_user/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/constants/app_strings.dart';

class RemedyServicesSection extends StatelessWidget {
  const RemedyServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        'image': 'assets/images/remedy_chest.png',
        'title': 'Free Remedy\nBlogs',
        'buttonText': 'Explore',
        'buttonColor': const Color(0xFFF5E6D3),
        'buttonTextColor': const Color(0xFF8B6F47),
        'isShop': false,
      },
      {
        'image': 'https://images.pexels.com/photos/3796810/pexels-photo-3796810.jpeg?auto=compress&cs=tinysrgb&w=400',
        'title': 'Paid Remedy\nSessions',
        'buttonText': 'Book Now',
        'buttonColor': const Color(0xFFFCE4EC),
        'buttonTextColor': const Color(0xFFD81B60),
        'isShop': false,
      },
      {
        'image': 'assets/images/gemstones_plate.png',
        'title': 'Gemstones',
        'buttonText': 'Shop Now',
        'buttonColor': const Color(0xFFFFB74D),
        'buttonTextColor': Colors.white,
        'isShop': true,
      },
      {
        'image': 'assets/images/healing_bracelets.png',
        'title': 'Bracelets',
        'buttonText': 'Shop Now',
        'buttonColor': const Color(0xFFFFB74D),
        'buttonTextColor': Colors.white,
        'isShop': true,
      },
    ];

    return Container(
      padding: const EdgeInsets.only(top: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF0F5),
            Color(0xFFFCE4EC),
          ],
        ),
      ),
      child: Column(
        children: [
          // Title with sparkle icons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.goldAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const AppText(
                  'Explore Remedy Blogs & Services',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepPink,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.goldAccent,
                  size: 18,
                ),
              ],
            ),
          ),

          
          // 2x2 Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return _buildServiceCard(
                  image: service['image'] as String,
                  title: service['title'] as String,
                  buttonText: service['buttonText'] as String,
                  buttonColor: service['buttonColor'] as Color,
                  buttonTextColor: service['buttonTextColor'] as Color,
                  isShop: service['isShop'] as bool,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required String image,
    required String title,
    required String buttonText,
    required Color buttonColor,
    required Color buttonTextColor,
    bool isShop = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image
          Container(
            height: 100,
            // margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: image.startsWith('http')
                    ? NetworkImage(image)
                    : AssetImage(image) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 10),
            child: AppText(
              title,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.deepPink,
              textAlign: TextAlign.center,
              // height: 1.2,
            ),
          ),
          // Button
          Container(
            margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
            child: CustomButton(
              height: 35,
                backgroundColor: buttonColor,
                textColor: buttonTextColor,
                text: buttonText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
