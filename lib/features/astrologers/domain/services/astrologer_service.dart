import '../../../../core/services/network/response_model.dart';
import '../repositories/astrologer_repository.dart';

class AstrologerService {
  final AstrologerRepository repository;

  AstrologerService({required this.repository});

  Future<ResponseModel> getAstrologers({Map<String, dynamic>? queryParameters}) async {
    return await repository.getAstrologers(queryParameters: queryParameters);
  }

  Future<ResponseModel> getAstrologerById(int id) async {
    return await repository.getAstrologerById(id);
  }

  Future<ResponseModel> getAstrologerGallery(int id) async {
    return await repository.getAstrologerGallery(id);
  }

  Future<ResponseModel> blockAstrologer(int id, {String? reason}) async {
    return await repository.blockAstrologer(id, reason: reason);
  }

  Future<ResponseModel> unblockAstrologer(int id) async {
    return await repository.unblockAstrologer(id);
  }

  Future<ResponseModel> getBlockedAstrologers({Map<String, dynamic>? queryParameters}) async {
    return await repository.getBlockedAstrologers(queryParameters: queryParameters);
  }

  Future<ResponseModel> reportAstrologer(int id, String reason) async {
    return await repository.reportAstrologer(id, reason);
  }

  Future<ResponseModel> postReview(int astrologerId, int rating, String review) async {
    return await repository.postReview(astrologerId, rating, review);
  }

  Future<ResponseModel> getReviews(int astrologerId) async {
    return await repository.getReviews(astrologerId);
  }

  Future<ResponseModel> followAstrologer(int id) async {
    return await repository.followAstrologer(id);
  }
}
