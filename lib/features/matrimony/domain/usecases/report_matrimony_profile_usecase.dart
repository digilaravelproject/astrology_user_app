import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/matrimony/data/datasources/matrimony_service.dart';

class ReportMatrimonyProfileUseCase {
  final MatrimonyServiceInterface service;

  ReportMatrimonyProfileUseCase({required this.service});

  Future<ResponseModel> execute(int id, String reason) async {
    return await service.reportProfile(id, reason);
  }
}
