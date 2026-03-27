import '../../../../core/services/network/response_model.dart';
import '../services/matrimony_service.dart';

class GetMatrimonyProfileUseCase {
  final MatrimonyServiceInterface service;

  GetMatrimonyProfileUseCase({required this.service});

  Future<ResponseModel> execute() async {
    return await service.getMatrimonyProfile();
  }
}
