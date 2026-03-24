import 'package:image_picker/image_picker.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/multipart.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';

class ProfileRepository {
  final ApiClient apiClient;

  ProfileRepository(this.apiClient);

  Future<ResponseModel> updateProfilePhoto(XFile imageFile) async {
    MultipartBody multipartBody = MultipartBody('profile_photo', imageFile);

    return await apiClient.postMultipartData(
      AppUrls.updateProfilePhoto,
      {},
      [multipartBody],
      [],
    );
  }

  Future<ResponseModel> getProfile(int id) async {
    return await apiClient.get(AppUrls.getProfile(id));
  }

  Future<ResponseModel> updateProfileInApp(Map<String, dynamic> data) async {
    return await apiClient.put(AppUrls.updateProfileInApp, data: data);
  }
}
