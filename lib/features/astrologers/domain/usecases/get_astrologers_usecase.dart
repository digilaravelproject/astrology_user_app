import '../../../../core/services/network/response_model.dart';
import '../models/astrologer_model.dart';
import '../services/astrologer_service.dart';

class GetAstrologersUseCase {
  final AstrologerService service;

  GetAstrologersUseCase({required this.service});

  Future<List<AstrologerModel>> execute() async {
    final response = await service.getAstrologers();
    if (response.isSuccess && response.body != null) {
      final List<dynamic> data = response.body['astrologers'] ?? [];
      return data.map((json) => AstrologerModel.fromJson(json)).toList();
    }
    return [];
  }
}
