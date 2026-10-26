import 'package:image_picker/image_picker.dart';
import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/matrimony/data/datasources/matrimony_service.dart';
import 'package:astro_user/features/matrimony/data/models/matrimony_profile_model.dart';

class SaveMatrimonyProfileUseCase {
  final MatrimonyServiceInterface service;

  SaveMatrimonyProfileUseCase({required this.service});

  Future<ResponseModel> execute(MatrimonyProfileModel profile, XFile? photo) {
    return service.saveProfile(profile, photo);
  }
}
