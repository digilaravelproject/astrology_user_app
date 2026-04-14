import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';

class AstrologerRepository {
  final ApiClient apiClient;

  AstrologerRepository({required this.apiClient});

  Future<ResponseModel> getAstrologers({Map<String, dynamic>? queryParameters}) async {
    return await apiClient.get(AppUrls.astrologers, queryParameters: queryParameters);
  }

  Future<ResponseModel> getAstrologerById(int id) async {
    return await apiClient.get('${AppUrls.astrologers}/$id');
  }

  Future<ResponseModel> blockAstrologer(int id) async {
    return await apiClient.post(AppUrls.blockAstrologer(id));
  }

  Future<ResponseModel> reportAstrologer(int id, String reason) async {
    return await apiClient.post('${AppUrls.astrologers}/$id/report', data: {'reason': reason});
  }

  Future<ResponseModel> postReview(int astrologerId, int rating, String review) async {
    return await apiClient.post('/api/v1/user/reviews', data: {
      'astrologer_id': astrologerId,
      'rating': rating,
      'review': review,
    });
  }

  Future<ResponseModel> getReviews(int astrologerId) async {
    return await apiClient.get('/api/v1/user/reviews', queryParameters: {'astrologer_id': astrologerId});
  }

  Future<ResponseModel> followAstrologer(int id) async {
    return await apiClient.post('${AppUrls.astrologers}/$id/follow');
  }
}
