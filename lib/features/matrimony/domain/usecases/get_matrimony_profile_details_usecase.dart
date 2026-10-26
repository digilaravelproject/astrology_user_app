import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/matrimony/data/datasources/matrimony_service.dart';

class GetMatrimonyProfileDetailsUseCase {
  final MatrimonyServiceInterface _service;

  GetMatrimonyProfileDetailsUseCase(this._service);

  Future<ResponseModel> execute(int id) async {
    return await _service.getMatrimonyProfileDetails(id);
  }
}
