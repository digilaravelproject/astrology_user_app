import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text.dart';
import '../../remedy/screens/remedy_detail_screen.dart';
import '../../home/controllers/remedy_controller.dart';
import '../../home/domain/models/remedy_model.dart';

class RemedyGrid extends StatelessWidget {
  const RemedyGrid({Key? key}) : super(key: key);

  // Cycle through these colors to give each remedy card a distinct look
  static const List<Color> _cardColors = [
    Color(0xFFD32F2F),
    Color(0xFF5D4037),
    Color(0xFFE65100),
    Color(0xFFC2185B),
    Color(0xFFFF6347),
    Color(0xFFFF6F00),
  ];

  @override
  Widget build(BuildContext context) {
    final remedyController = Get.find<RemedyController>();

    return Obx(() {
      if (remedyController.isLoading.value) {
        return const SizedBox(
          height: 150,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.deepPink,
              strokeWidth: 2,
            ),
          ),
        );
      }

      if (remedyController.remedies.isEmpty) {
        return const SizedBox(
          height: 150,
          child: Center(
            child: AppText(
              'No remedies found',
              fontSize: 14,
              color: Colors.black45,
            ),
          ),
        );
      }

      return SizedBox(
        height: 150,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          scrollDirection: Axis.horizontal,
          itemCount: remedyController.remedies.length,
          itemBuilder: (context, index) {
            final remedy = remedyController.remedies[index];
            final color = _cardColors[index % _cardColors.length];
            final imageUrl = remedyController.getRemedyImage(index);
            return GestureDetector(
              onTap: () {
                Get.to(() => RemedyDetailScreen(
                  remedyId: remedy.id,
                  accentColor: color,
                  imageUrl: imageUrl,
                ));
              },
              child: Container(
                width: 200,
                margin: EdgeInsets.only(
                  right: index < remedyController.remedies.length - 1 ? 12 : 0,
                ),
                child: _buildRemedyCard(remedy, color),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildRemedyCard(RemedyModel remedy, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 0.9,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and title row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_fix_high_rounded, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText(
                    remedy.title,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Expanded(
              child: AppText(
                remedy.description,
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
                height: 1.35,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.arrow_forward_ios_rounded, size: 10, color: color.withOpacity(0.8)),
                const SizedBox(width: 4),
                AppText(
                  AppStrings.viewMore,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
