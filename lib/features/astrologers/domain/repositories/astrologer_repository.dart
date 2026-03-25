import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';

class AstrologerRepository {
  final ApiClient apiClient;

  AstrologerRepository({required this.apiClient});

  Future<ResponseModel> getAstrologers() async {
    return await apiClient.get(AppUrls.astrologers);
  }
}
