import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_image_widget.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';

class ServiceIconGrid extends StatelessWidget {
  const ServiceIconGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {"name": AppStrings.dailyHoroscope, "path": "assets/images/services/daily_horoscope.png"},
      {"name": AppStrings.freeKundli, "path": "assets/images/services/free_kundli.png"},
      {"name": AppStrings.matchMaking, "path": "assets/images/services/match_making.png"},
      {"name": AppStrings.dailyPanchang, "path": "assets/images/services/daily_panchang.png"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: services.map((s) => Expanded(
          child: _buildServiceItem(
            s['name'] as String,
            s['path'] as String,
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildServiceItem(String name, String assetPath) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 65,
          height: 65,
          child: CustomImageWidget(
            imagePath: assetPath,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 10),
        AppText(
          name,
          textAlign: TextAlign.center,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2E1A47),
          height: 1.2,
        ),
      ],
    );
  }
}
