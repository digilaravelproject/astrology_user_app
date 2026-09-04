import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/astrologers/data/datasources/astrologer_service.dart';

class PostReviewUseCase {
  final AstrologerService service;

  PostReviewUseCase({required this.service});

  Future<ResponseModel> execute(int astrologerId, int rating, String review) async {
    return await service.postReview(astrologerId, rating, review);
  }
}
