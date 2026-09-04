import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/constants/app_constants.dart';
import 'package:astro_user/core/services/storage/shared_prefs.dart';

class FounderRepository {
  final ApiClient apiClient;

  FounderRepository(this.apiClient);

  Future<ResponseModel> getFounderWords() async {
    final languageCode = SharedPrefs.getString(AppConstants.language) ?? AppConstants.defaultLanguage;
    return await apiClient.get(
      AppUrls.foundersWords,
      queryParameters: {'language': languageCode},
    );
  }
}
