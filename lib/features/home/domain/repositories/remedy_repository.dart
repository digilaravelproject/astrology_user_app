import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/constants/app_constants.dart';
import 'package:astro_user/core/services/storage/shared_prefs.dart';
class RemedyRepository {
  final ApiClient apiClient;

  RemedyRepository(this.apiClient);

  Future<ResponseModel> getRemedies() async {
    final languageCode = SharedPrefs.getString(AppConstants.language) ?? AppConstants.defaultLanguage;
    return await apiClient.get(
      AppUrls.remedies,
      queryParameters: {'language': languageCode},
    );
  }

  Future<ResponseModel> getRemedyById(int id) async {
    final languageCode = SharedPrefs.getString(AppConstants.language) ?? AppConstants.defaultLanguage;
    return await apiClient.get(
      "${AppUrls.remedies}/$id",
      queryParameters: {'language': languageCode},
    );
  }
}
