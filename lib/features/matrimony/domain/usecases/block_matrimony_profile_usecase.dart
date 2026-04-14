import '../../../../core/services/network/response_model.dart';
import '../services/matrimony_service.dart';

class BlockMatrimonyProfileUseCase {
  final MatrimonyServiceInterface service;

  BlockMatrimonyProfileUseCase({required this.service});

  Future<ResponseModel> execute(int id) async {
    return await service.blockProfile(id);
  }
}
