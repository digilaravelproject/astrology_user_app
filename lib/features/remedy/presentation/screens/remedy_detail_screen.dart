import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:astro_user/core/widgets/custom_app_bar.dart';
import 'package:astro_user/core/widgets/custom_image_widget.dart';
import 'package:astro_user/features/home/presentation/controllers/remedy_controller.dart';
import 'package:astro_user/features/home/data/models/remedy_model.dart';

class RemedyDetailScreen extends StatefulWidget {
  final int remedyId;
  final Color accentColor;
  final String imageUrl;

  const RemedyDetailScreen({
    Key? key,
    required this.remedyId,
    required this.imageUrl,
    this.accentColor = AppColors.deepPink,
  }) : super(key: key);

  @override
  State<RemedyDetailScreen> createState() => _RemedyDetailScreenState();
}

class _RemedyDetailScreenState extends State<RemedyDetailScreen> {
  RemedyModel? _remedy;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final controller = Get.find<RemedyController>();
    final result = await controller.fetchRemedyById(widget.remedyId);
    if (mounted) {
      setState(() {
        _remedy = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Remedy Details".tr,
        backgroundColor: Colors.white,
        iconColor: Colors.black,
        elevation: 0.5,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: widget.accentColor,
              strokeWidth: 2,
            ))
          : _remedy == null
              ? Center(
                  child: AppText('Could not load remedy detail.'.tr,
                    fontSize: 15,
                    color: Colors.black45,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Image Header
                      if (widget.imageUrl.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CustomImageWidget(
                              imagePath: widget.imageUrl,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Remedy Title
                            AppText(
                              _remedy!.title,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2E1A47),
                              height: 1.3,
                            ),

                            const SizedBox(height: 16),
                            
                            const Divider(height: 1),
                            
                            const SizedBox(height: 20),

                            // Remedy Description
                            AppText(
                              _remedy!.description,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                              height: 1.6,
                            ),

                            const SizedBox(height: 40),

                            // Disclaimer
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black.withOpacity(0.05)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blueGrey, size: 20),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: AppText('Consult with an expert astrologer for personalized remedies based on your birth chart.'.tr,
                                      fontSize: 12,
                                      color: Colors.blueGrey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
