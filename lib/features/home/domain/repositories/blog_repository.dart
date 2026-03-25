import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';

class BlogRepository {
  final ApiClient apiClient;

  BlogRepository(this.apiClient);

  Future<ResponseModel> getBlogs() async {
    return await apiClient.get(AppUrls.blogs);
  }

  Future<ResponseModel> getBlogById(int id) async {
    return await apiClient.get("${AppUrls.blogs}/$id");
  }
}
