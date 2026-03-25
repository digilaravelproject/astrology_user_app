import 'package:image_picker/image_picker.dart';
import '../../../../core/services/network/response_model.dart';
import '../services/matrimony_service.dart';
import '../models/matrimony_profile_model.dart';

class SaveMatrimonyProfileUseCase {
  final MatrimonyServiceInterface service;

  SaveMatrimonyProfileUseCase({required this.service});

  Future<ResponseModel> execute(MatrimonyProfileModel profile, XFile? photo) {
    return service.saveProfile(profile, photo);
  }
}
