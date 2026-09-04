import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/matrimony/data/datasources/matrimony_service.dart';

class BlockMatrimonyProfileUseCase {
  final MatrimonyServiceInterface service;

  BlockMatrimonyProfileUseCase({required this.service});

  Future<ResponseModel> execute(int id) async {
    return await service.blockProfile(id);
  }
}
