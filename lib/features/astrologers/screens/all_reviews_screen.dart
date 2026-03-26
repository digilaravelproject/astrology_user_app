import 'package:astro_user/core/constants/app_urls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_rating_bar.dart';
import '../../astrologers/controllers/astrologer_controller.dart';
import '../../astrologers/domain/models/review_model.dart';
import 'astrologer_detail_screen.dart';

class AllReviewsScreen extends StatefulWidget {
  final int astrologerId;

  const AllReviewsScreen({
    Key? key,
    required this.astrologerId,
  }) : super(key: key);

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
            child: AppText(
              'No reviews yet',
              fontSize: 16,
              color: Colors.grey,
            ),
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
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  AppUrls.baseImageUrl + (review.user?.profilePhoto ?? ''),
                ),              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppText(
                  review.user?.name ?? 'Unknown',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF880E4F),
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
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF880E4F),
            style: const TextStyle(height: 1.4),
          ),
          if (review.reply != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEbee),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Vera', fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF4A148C)),
                  const SizedBox(height: 4),
                  AppText(
                    review.reply!,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF4A148C),
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
