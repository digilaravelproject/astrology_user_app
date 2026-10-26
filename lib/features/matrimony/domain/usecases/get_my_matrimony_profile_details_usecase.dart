import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/matrimony/data/datasources/matrimony_service.dart';

class GetMyMatrimonyProfileDetailsUseCase {
  final MatrimonyServiceInterface _service;

  GetMyMatrimonyProfileDetailsUseCase(this._service);

  Future<ResponseModel> execute(int userId) async {
    return await _service.getMyMatrimonyProfileDetails(userId);
  }
}
