import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/matrimony/data/datasources/matrimony_service.dart';

class GetMatrimonyProfileUseCase {
  final MatrimonyServiceInterface service;

  GetMatrimonyProfileUseCase({required this.service});

  Future<ResponseModel> execute() async {
    return await service.getMatrimonyProfile();
  }
}
