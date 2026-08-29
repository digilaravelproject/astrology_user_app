import 'package:image_picker/image_picker.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/multipart.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';
import '../models/matrimony_profile_model.dart';

abstract class MatrimonyRepositoryInterface {
  Future<ResponseModel> saveProfile(
    MatrimonyProfileModel profile,
    XFile? photo,
  );
  Future<ResponseModel> updateProfile(
    MatrimonyProfileModel profile,
    XFile? photo,
  );
  Future<ResponseModel> getMatrimonyProfile();
  Future<ResponseModel> getMatrimonyProfileDetails(int id);
  Future<ResponseModel> getMyMatrimonyProfileDetails(int userId);
  Future<ResponseModel> searchMatrimonyProfiles(String query);
  Future<ResponseModel> blockProfile(int id);
  Future<ResponseModel> reportProfile(int id, String reason);
}

class MatrimonyRepository implements MatrimonyRepositoryInterface {
  final ApiClient apiClient;

  MatrimonyRepository({required this.apiClient});

  @override
  Future<ResponseModel> saveProfile(
    MatrimonyProfileModel profile,
    XFile? photo,
  ) async {
    return await apiClient.postMultipartData(
      AppUrls.matrimonyProfile,
      profile.toFormFields(),
      [MultipartBody('profile_photo', photo)],
      [],
    );
  }

  @override
  Future<ResponseModel> updateProfile(
    MatrimonyProfileModel profile,
    XFile? photo,
  ) async {
    return await apiClient.postMultipartData(
      AppUrls.updateMatrimonyProfile,
      profile.toFormFields(),
      [MultipartBody('profile_photo', photo)],
      [],
    );
  }

  @override
  Future<ResponseModel> getMatrimonyProfile() async {
    return await apiClient.get(AppUrls.getMatrimonyProfile);
  }

  @override
  Future<ResponseModel> getMatrimonyProfileDetails(int id) async {
    return await apiClient.get(AppUrls.getMatrimonyProfileDetails(id));
  }

  @override
  Future<ResponseModel> getMyMatrimonyProfileDetails(int userId) async {
    return await apiClient.get(AppUrls.getMyMatrimonyProfileDetails(userId));
  }

  @override
  Future<ResponseModel> searchMatrimonyProfiles(String query) async {
    return await apiClient.get(AppUrls.matrimonySearch(query));
  }

  @override
  Future<ResponseModel> blockProfile(int id) async {
    return await apiClient.post(AppUrls.blockMatrimonyProfile(id));
  }

  @override
  Future<ResponseModel> reportProfile(int id, String reason) async {
    return await apiClient.post(
      AppUrls.reportMatrimonyProfile(id),
      data: {'reason': reason},
    );
  }
}
