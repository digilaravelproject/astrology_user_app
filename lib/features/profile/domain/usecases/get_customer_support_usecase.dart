import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/profile/data/datasources/profile_service.dart';

class GetCustomerSupportUseCase {
  final ProfileService _service;

  GetCustomerSupportUseCase(this._service);

  Future<ResponseModel> execute() async {
    return await _service.getCustomerSupport();
  }
}
