import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_image_widget.dart';
import '../../../core/widgets/app_text.dart';
import '../../home/controllers/remedy_controller.dart';
import 'remedy_detail_screen.dart';

class RemedyListScreen extends StatelessWidget {
  const RemedyListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final remedyController = Get.find<RemedyController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AppText(
          'All Remedies'.tr,
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (remedyController.isLoading.value &&
            remedyController.remedies.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (remedyController.remedies.isEmpty) {
          return Center(child: AppText('No remedies available.'.tr));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.45,
          ),
          itemCount: remedyController.remedies.length,
          itemBuilder: (context, index) {
            final remedy = remedyController.remedies[index];
            final imageUrl =
                remedy.image ?? remedyController.getRemedyImage(index);

            return GestureDetector(
              onTap: () {
                Get.to(
                  () => RemedyDetailScreen(
                    remedyId: remedy.id,
                    accentColor: AppColors.primaryColor,
                    imageUrl: imageUrl,
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // Full Card Image
                      Positioned.fill(
                        child: CustomImageWidget(
                          imagePath: imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Smooth Bottom Dark Gradient Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.15),
                                Colors.black.withOpacity(0.75),
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Overlay Title Text
                      Positioned(
                        bottom: 8,
                        left: 10,
                        right: 10,
                        child: Text(
                          remedy.title,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.25,
                            shadows: [
                              Shadow(
                                color: Colors.black87,
                                offset: Offset(0, 1.5),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
