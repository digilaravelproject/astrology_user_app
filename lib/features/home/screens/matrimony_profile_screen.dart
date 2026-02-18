import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class MatrimonyProfileScreen extends StatelessWidget {
  final Map<String, dynamic> profile;

  const MatrimonyProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5), // Light pink background
      appBar: const CustomAppBar(
        title: 'NSK576590',
        backgroundColor: Color(0xFFFFF0F5),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildPersonalInformation(), // Moved up based on typical flow
            const SizedBox(height: 16),
            _buildContactInformation(), // Moved down
            const SizedBox(height: 16),
            _buildAboutMyself(),
            const SizedBox(height: 16),
            _buildLifestyle(),
            const SizedBox(height: 16),
            // Reordered based on user feedback "ishi sequence mey rakho"
            _buildPartnerPreferencesHeader(),
            const SizedBox(height: 16),
            _buildIgnoredSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 250,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(profile['image'] ?? profile['imageUrl'] ?? 'https://randomuser.me/api/portraits/women/65.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  'Ratnaprabha Rajendra Gawas',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF880E4F),
                ),
              ),
              Row(
                children: [
                   Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE91E63)),
                    ),
                    child: const Icon(Icons.call_outlined, color: Color(0xFFE91E63), size: 20),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF4CAF50)),
                    ),
                    child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF4CAF50), size: 20),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              AppText(
                'NSK576590',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              AppText(
                AppStrings.lastSeenFewHoursAgo,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(AppStrings.neverMarried, isFirst: true),
          _buildInfoRow(AppStrings.profileCreatedBySelfInfo),
          _buildInfoRow(AppStrings.bachelorDegreeInfo),
          _buildInfoRow(AppStrings.managementHealthcareInfo),
          
          const SizedBox(height: 24),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD81B60), Color(0xFFAD1457)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: AppText(
              AppStrings.viewPersonalInformation,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String text, {bool isFirst = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.pink[100],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppText(
              text,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4A148C),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCDD2).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, color: Color(0xFF880E4F)),
              ),
              const SizedBox(width: 12),
              AppText(
                AppStrings.personalInformation,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF880E4F),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow(AppStrings.age, '36 Years and 3 months'),
          _buildDetailRow(AppStrings.height, '5\'0"'),
          _buildDetailRow(AppStrings.spokenLanguages, 'Marathi (Mother Tongue)'),
          _buildDetailRow(AppStrings.profileCreatedBy, 'Self'),
          _buildDetailRow(AppStrings.maritalStatus, AppStrings.neverMarried),
          _buildDetailRow(AppStrings.livesIn, 'Mumbai, Maharashtra'),
          _buildDetailRow(AppStrings.eatingHabits, 'Not specified'),
          _buildDetailRow(AppStrings.religion, 'Hindu'),
          _buildDetailRow(AppStrings.subcaste, '96 Kuli Koknastha'),
          _buildDetailRow(AppStrings.manglik, 'No'),
          _buildDetailRow(AppStrings.employment, 'Works in Private Sector', isLink: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: AppText(
              label,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const AppText(':  '),
          Expanded(
            child: AppText(
              value,
              fontSize: 14,
              fontWeight: isLink ? FontWeight.w500 : FontWeight.w600,
              color: isLink ? const Color(0xFFE91E63) : const Color(0xFF212121),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInformation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5), // Light pink background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCDD2).withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                ),
                child: const Icon(Icons.call, color: Color(0xFF4E342E), size: 20),
              ),
              const SizedBox(width: 12),
              AppText(
                AppStrings.contactInformation,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4A0033),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              AppText(
                AppStrings.mobileNumber,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              const SizedBox(width: 24),
              const AppText(':  '),
              AppText(
                '+91 88*******',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 14, color: Color(0xFFE91E63)),
                const SizedBox(width: 4),
                AppText(
                  AppStrings.upgradeToView,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFE91E63),
                ),
                const Icon(Icons.chevron_right, size: 16, color: Color(0xFFE91E63)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutMyself() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCDD2).withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                ),
                child: const Icon(Icons.person_outline, color: Color(0xFF4E342E), size: 20),
              ),
              const SizedBox(width: 12),
              AppText(
                AppStrings.aboutMyself,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4A0033),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            AppStrings.aboutMyselfDescription,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
            height: 1.5,
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCDD2).withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                ),
                child: const Icon(Icons.restaurant, color: Color(0xFF4E342E), size: 20),
              ),
              const SizedBox(width: 12),
              AppText(
                AppStrings.lifestyle,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4A0033),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(AppStrings.cuisine, "I'm a foodie, Konkan"),
          _buildDetailRow(AppStrings.hobbies, 'Cooking, Nature, Photography'),
          _buildDetailRow(AppStrings.music, 'Indian classical'),
          _buildDetailRow(AppStrings.sports, "I'm not a sportsperson"),
          _buildDetailRow(AppStrings.smokingHabits, 'Not specified'),
          _buildDetailRow(AppStrings.drinkingHabits, 'Not specified'),
        ],
      ),
    );
  }

  Widget _buildPartnerPreferencesHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star, color: Color(0xFFE1BEE7), size: 20), // Placeholder for sparkles
          const SizedBox(width: 8),
          AppText(
            AppStrings.herPartnerPreferences,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF880E4F),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.star, color: Color(0xFFE1BEE7), size: 20),
        ],
      ),
    );
  }

  Widget _buildIgnoredSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            AppStrings.youIgnoredThisProfile,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF880E4F),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.5)),
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: AppText(
              AppStrings.removeFromIgnoredList,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF880E4F),
            ),
          ),
        ],
      ),
    );
  }
}
