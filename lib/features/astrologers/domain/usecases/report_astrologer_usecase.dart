import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/astrologers/data/datasources/astrologer_service.dart';

class ReportAstrologerUseCase {
  final AstrologerService service;

  ReportAstrologerUseCase({required this.service});

  Future<ResponseModel> execute(int id, String reason) async {
    return await service.reportAstrologer(id, reason);
  }
}
