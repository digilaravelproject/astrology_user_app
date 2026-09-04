import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/astrologers/data/models/astrologer_model.dart';
import 'package:astro_user/features/astrologers/data/datasources/astrologer_service.dart';

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
