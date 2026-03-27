import '../../../../features/auth/domain/models/user_model.dart';
import '../services/profile_service.dart';

class GetProfileUseCase {
  final ProfileService _profileService;

  GetProfileUseCase(this._profileService);

  Future<UserModel?> execute(int id) async {
    final response = await _profileService.getProfile(id);

    if (response.isSuccess && response.body != null) {
      try {
        final Map<String, dynamic> bodyMap = response.body as Map<String, dynamic>;
        print('GetProfileUseCase: bodyMap=$bodyMap');
        
        // API returns {status: success, data: {user: {...}}}
        // So we need to get data first, then user
        final Map<String, dynamic> data = bodyMap['data'] as Map<String, dynamic>;
        final Map<String, dynamic> userJson = data['user'] as Map<String, dynamic>;
        print('GetProfileUseCase: userJson=$userJson');
        return UserModel.fromJson(userJson);
      } catch (e) {
        print('Error parsing GetProfile data: $e');
      }
    }

    return null;
  }
}
