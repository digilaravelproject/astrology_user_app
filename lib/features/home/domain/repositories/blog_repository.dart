import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/constants/app_constants.dart';
import 'package:astro_user/core/services/storage/shared_prefs.dart';
class BlogRepository {
  final ApiClient apiClient;

  BlogRepository(this.apiClient);

  Future<ResponseModel> getBlogs() async {
    final languageCode = SharedPrefs.getString(AppConstants.language) ?? AppConstants.defaultLanguage;
    return await apiClient.get(
      AppUrls.blogs,
      queryParameters: {'language': languageCode},
    );
  }

  Future<ResponseModel> getBlogById(int id) async {
    final languageCode = SharedPrefs.getString(AppConstants.language) ?? AppConstants.defaultLanguage;
    return await apiClient.get(
      "${AppUrls.blogs}/$id",
      queryParameters: {'language': languageCode},
    );
  }
}
