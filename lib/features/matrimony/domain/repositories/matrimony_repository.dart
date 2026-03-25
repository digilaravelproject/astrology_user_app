import 'package:image_picker/image_picker.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/multipart.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';
import '../models/matrimony_profile_model.dart';

abstract class MatrimonyRepositoryInterface {
  Future<ResponseModel> saveProfile(MatrimonyProfileModel profile, XFile? photo);
}

class MatrimonyRepository implements MatrimonyRepositoryInterface {
  final ApiClient apiClient;

  MatrimonyRepository({required this.apiClient});

  @override
  Future<ResponseModel> saveProfile(MatrimonyProfileModel profile, XFile? photo) async {
    return await apiClient.postMultipartData(
      AppUrls.matrimonyProfile,
      profile.toFormFields(),
      [MultipartBody('profile_photo', photo)],
      [],
    );
  }
}
