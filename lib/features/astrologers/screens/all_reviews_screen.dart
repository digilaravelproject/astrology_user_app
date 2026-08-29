import 'package:astro_user/core/constants/app_urls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_image_widget.dart';
import '../../../core/widgets/custom_rating_bar.dart';
import '../../astrologers/controllers/astrologer_controller.dart';
import '../../astrologers/domain/models/review_model.dart';
import 'astrologer_detail_screen.dart';

class AllReviewsScreen extends StatefulWidget {
  final int astrologerId;

  const AllReviewsScreen({Key? key, required this.astrologerId})
    : super(key: key);

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  final AstrologerController _controller = Get.find<AstrologerController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchReviews(widget.astrologerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppText(
          'All Reviews',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2D2D2D),
        ),
      ),
      body: Obx(() {
        final reviews = _controller.reviews;

        if (reviews.isEmpty) {
          return const Center(
            child: AppText('No reviews yet', fontSize: 16, color: Colors.grey),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            return _buildReviewCard(reviews[index]);
          },
        );
      }),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomImageWidget(
                imagePath: AppUrls.baseImageUrl + (review.user?.profilePhoto ?? ''),
                height: 36,
                width: 36,
                radius: BorderRadius.circular(18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppText(
                  review.user?.name ?? 'Unknown',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              //const Icon(Icons.more_vert, size: 20, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          CustomRatingBar(rating: review.rating, size: 16),
          const SizedBox(height: 8),
          AppText(
            review.review,
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade700,
            style: const TextStyle(height: 1.4),
          ),
          if (review.reply != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
              margin: const EdgeInsets.only(left: 4, top: 4),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300, width: 2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Reply from Astrologer',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    review.reply!,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade700,
                    style: const TextStyle(height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
