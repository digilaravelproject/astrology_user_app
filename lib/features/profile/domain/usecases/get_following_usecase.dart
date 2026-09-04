import 'package:astro_user/features/profile/data/datasources/profile_service.dart';
import 'package:astro_user/core/services/network/response_model.dart';

class GetFollowingUseCase {
  final ProfileService _profileService;

  GetFollowingUseCase(this._profileService);

  Future<ResponseModel> execute() async {
    return await _profileService.getFollowing();
  }
}
