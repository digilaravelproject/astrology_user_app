import '../../../../core/services/network/response_model.dart';
import '../services/profile_service.dart';

class GetCustomerSupportUseCase {
  final ProfileService _service;

  GetCustomerSupportUseCase(this._service);

  Future<ResponseModel> execute() async {
    return await _service.getCustomerSupport();
  }
}
