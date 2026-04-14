import '../../../../core/services/network/response_model.dart';
import '../services/profile_service.dart';

class GetAboutUsUseCase {
  final ProfileService service;

  GetAboutUsUseCase(this.service);

  Future<ResponseModel> execute() async {
    return await service.getAboutUs();
  }
}
