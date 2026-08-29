import 'package:image_picker/image_picker.dart';
import '../../../../core/services/network/response_model.dart';
import '../services/matrimony_service.dart';
import '../models/matrimony_profile_model.dart';

class UpdateMatrimonyProfileUseCase {
  final MatrimonyServiceInterface _service;

  UpdateMatrimonyProfileUseCase({required MatrimonyServiceInterface service})
    : _service = service;

  Future<ResponseModel> execute(
    MatrimonyProfileModel profile,
    XFile? photo,
  ) async {
    return await _service.updateProfile(profile, photo);
  }
}
