import '../../../../features/auth/domain/models/user_model.dart';
import '../services/profile_service.dart';

class UpdateProfileInAppUseCase {
  final ProfileService _profileService;

  UpdateProfileInAppUseCase(this._profileService);

  Future<UserModel?> execute(Map<String, dynamic> data) async {
    final response = await _profileService.updateProfileInApp(data);

    if (response.isSuccess && response.body != null) {
      try {
        final Map<String, dynamic> bodyMap =
            response.body as Map<String, dynamic>;
        final Map<String, dynamic> userJson =
            bodyMap.containsKey('user') ? bodyMap['user'] : bodyMap;
        return UserModel.fromJson(userJson);
      } catch (e) {
        print('Error parsing UpdateProfileInApp data: $e');
      }
    }

    return null;
  }
}
