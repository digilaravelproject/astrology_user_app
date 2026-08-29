import '../../../../core/services/network/response_model.dart';
import '../models/review_model.dart';
import '../services/astrologer_service.dart';

class GetReviewsUseCase {
  final AstrologerService service;

  GetReviewsUseCase({required this.service});

  Future<List<ReviewModel>> execute(int astrologerId) async {
    final response = await service.getReviews(astrologerId);
    if (response.isSuccess && response.body != null) {
      // Try to get reviews from data.reviews or directly from response.body
      final data = response.body['data'] as Map<String, dynamic>? ?? {};
      final reviews = data['reviews'] ?? response.body['reviews'] ?? [];
      return (reviews as List)
          .map((json) => ReviewModel.fromJson(json))
          .toList();
    }
    return [];
  }
}
