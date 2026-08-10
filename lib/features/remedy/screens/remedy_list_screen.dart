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
        title: AppText('All Remedies', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (remedyController.isLoading.value && remedyController.remedies.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (remedyController.remedies.isEmpty) {
          return Center(child: AppText('No remedies available.'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: remedyController.remedies.length,
          itemBuilder: (context, index) {
            final remedy = remedyController.remedies[index];
            final imageUrl = remedy.image ?? remedyController.getRemedyImage(index);

            return GestureDetector(
              onTap: () {
                Get.to(() => RemedyDetailScreen(
                  remedyId: remedy.id,
                  accentColor: AppColors.primaryColor,
                  imageUrl: imageUrl,
                ));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryColor.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: CustomImageWidget(
                          imagePath: imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppText(
                              remedy.title,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 2,
                              width: 30,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
