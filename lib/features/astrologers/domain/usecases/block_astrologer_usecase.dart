import '../../../../core/services/network/response_model.dart';
import '../services/astrologer_service.dart';

class BlockAstrologerUseCase {
  final AstrologerService service;

  BlockAstrologerUseCase({required this.service});

  Future<ResponseModel> execute(int id) async {
    return await service.blockAstrologer(id);
  }
}
