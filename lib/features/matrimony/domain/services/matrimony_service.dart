import 'package:image_picker/image_picker.dart';
import '../../../../core/services/network/response_model.dart';
import '../repositories/matrimony_repository.dart';
import '../models/matrimony_profile_model.dart';

abstract class MatrimonyServiceInterface {
  Future<ResponseModel> saveProfile(MatrimonyProfileModel profile, XFile? photo);
  Future<ResponseModel> updateProfile(MatrimonyProfileModel profile, XFile? photo);
  Future<ResponseModel> getMatrimonyProfile();
  Future<ResponseModel> getMatrimonyProfileDetails(int id);
  Future<ResponseModel> getMyMatrimonyProfileDetails(int userId);
  Future<ResponseModel> searchMatrimonyProfiles(String query);
  Future<ResponseModel> blockProfile(int id);
  Future<ResponseModel> reportProfile(int id, String reason);
}



class MatrimonyService implements MatrimonyServiceInterface {
  final MatrimonyRepositoryInterface repository;

  MatrimonyService({required this.repository});

  @override
  Future<ResponseModel> saveProfile(MatrimonyProfileModel profile, XFile? photo) {
    return repository.saveProfile(profile, photo);
  }

  @override
  Future<ResponseModel> updateProfile(MatrimonyProfileModel profile, XFile? photo) {
    return repository.updateProfile(profile, photo);
  }

  @override
  Future<ResponseModel> getMatrimonyProfile() {
    return repository.getMatrimonyProfile();
  }

  @override
  Future<ResponseModel> getMatrimonyProfileDetails(int id) async {
    return await repository.getMatrimonyProfileDetails(id);
  }

  @override
  Future<ResponseModel> getMyMatrimonyProfileDetails(int userId) async {
    return await repository.getMyMatrimonyProfileDetails(userId);
  }

  @override
  Future<ResponseModel> searchMatrimonyProfiles(String query) async {
    return await repository.searchMatrimonyProfiles(query);
  }

  @override
  Future<ResponseModel> blockProfile(int id) {
    return repository.blockProfile(id);
  }

  @override
  Future<ResponseModel> reportProfile(int id, String reason) {
    return repository.reportProfile(id, reason);
  }
}


