import '../services/profile_service.dart';
import '../../../../core/services/network/response_model.dart';

class GetFollowingUseCase {
  final ProfileService _profileService;

  GetFollowingUseCase(this._profileService);

  Future<ResponseModel> execute() async {
    return await _profileService.getFollowing();
  }
}
