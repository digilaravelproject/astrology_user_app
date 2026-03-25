import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';

class RemedyRepository {
  final ApiClient apiClient;

  RemedyRepository(this.apiClient);

  Future<ResponseModel> getRemedies() async {
    return await apiClient.get(AppUrls.remedies);
  }

  Future<ResponseModel> getRemedyById(int id) async {
    return await apiClient.get("${AppUrls.remedies}/$id");
  }
}
