import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/profile/data/datasources/profile_service.dart';

class GetAboutUsUseCase {
  final ProfileService service;

  GetAboutUsUseCase(this.service);

  Future<ResponseModel> execute() async {
    return await service.getAboutUs();
  }
}
