import '../../../../core/services/network/response_model.dart';
import '../models/astrologer_model.dart';
import '../services/astrologer_service.dart';

class GetAstrologerByIdUseCase {
  final AstrologerService service;

  GetAstrologerByIdUseCase({required this.service});

  Future<AstrologerModel?> execute(int id) async {
    final response = await service.getAstrologerById(id);
    if (response.isSuccess && response.body != null) {
      final data = response.body['astrologer'] ?? response.body;
      return AstrologerModel.fromJson(data);
    }
    return null;
  }
}
