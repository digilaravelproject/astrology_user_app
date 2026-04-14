import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';

class FounderRepository {
  final ApiClient apiClient;

  FounderRepository(this.apiClient);

  Future<ResponseModel> getFounderWords() async {
    return await apiClient.get(AppUrls.foundersWords);
  }
}
