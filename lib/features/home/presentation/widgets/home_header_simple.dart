import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_image_widget.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text.dart';
import 'package:get/get.dart';

class HomeHeaderSimple extends StatelessWidget {
  final String userName;
  final String? profileImageUrl;

  const HomeHeaderSimple({
    Key? key,
    required this.userName,
    this.profileImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                AppStrings.hello,
                fontSize: 26,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
                letterSpacing: -0.5,
              ),
              AppText(
                "$userName ",
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
                letterSpacing: -0.5,
              ),
              AppText("👋".tr,
                fontSize: 24,
              ),
            ],
          ),
          
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryColor.withOpacity(0.2), width: 2),
            ),
            child: CustomImageWidget(
              imagePath: profileImageUrl,
              height: 48,
              width: 48,
              radius: BorderRadius.circular(24),
              fallbackWidget: Container(
                height: 48,
                width: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: AppText(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
