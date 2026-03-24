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
        
        // Handling variations where user details might be within 'user' nested object or not
        final Map<String, dynamic> userJson = bodyMap.containsKey('user') ? bodyMap['user'] : bodyMap;
        return UserModel.fromJson(userJson);
      } catch (e) {
        print('Error parsing GetProfile data: $e');
      }
    }

    return null;
  }
}
