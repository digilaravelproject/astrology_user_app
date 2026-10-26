import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/astrologers/data/datasources/astrologer_service.dart';

class FollowAstrologerUseCase {
  final AstrologerService service;

  FollowAstrologerUseCase({required this.service});

  Future<ResponseModel> execute(int id) async {
    return await service.followAstrologer(id);
  }
}
