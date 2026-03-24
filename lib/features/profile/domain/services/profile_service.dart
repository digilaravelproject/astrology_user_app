import 'package:image_picker/image_picker.dart';
import '../../../../core/services/network/response_model.dart';
import '../repositories/profile_repository.dart';

class ProfileService {
  final ProfileRepository repository;

  ProfileService(this.repository);

  Future<ResponseModel> updateProfilePhoto(XFile imageFile) async {
    return await repository.updateProfilePhoto(imageFile);
  }

  Future<ResponseModel> getProfile(int id) async {
    return await repository.getProfile(id);
  }

  Future<ResponseModel> updateProfileInApp(Map<String, dynamic> data) async {
    return await repository.updateProfileInApp(data);
  }
}
