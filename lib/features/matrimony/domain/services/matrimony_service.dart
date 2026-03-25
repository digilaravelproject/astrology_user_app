import 'package:image_picker/image_picker.dart';
import '../../../../core/services/network/response_model.dart';
import '../repositories/matrimony_repository.dart';
import '../models/matrimony_profile_model.dart';

abstract class MatrimonyServiceInterface {
  Future<ResponseModel> saveProfile(MatrimonyProfileModel profile, XFile? photo);
}

class MatrimonyService implements MatrimonyServiceInterface {
  final MatrimonyRepositoryInterface repository;

  MatrimonyService({required this.repository});

  @override
  Future<ResponseModel> saveProfile(MatrimonyProfileModel profile, XFile? photo) {
    return repository.saveProfile(profile, photo);
  }
}
