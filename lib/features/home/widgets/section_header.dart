import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  final EdgeInsets? padding;

  const SectionHeader({
    Key? key,
    required this.title,
    required this.onSeeAll,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: AppText(
              title,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryColor,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: AppText(
              AppStrings.viewAll,
              color: AppColors.accentColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
