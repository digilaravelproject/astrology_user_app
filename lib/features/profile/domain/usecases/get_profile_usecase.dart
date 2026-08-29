import '../../../../features/auth/domain/models/user_model.dart';
import '../services/profile_service.dart';

class GetProfileUseCase {
  final ProfileService _profileService;

  GetProfileUseCase(this._profileService);

  Future<UserModel?> execute(int id) async {
    final response = await _profileService.getProfile(id);

    if (response.isSuccess && response.body != null) {
      try {
        final Map<String, dynamic> bodyMap =
            response.body as Map<String, dynamic>;
        print('GetProfileUseCase: bodyMap=$bodyMap');

        // Handle nesting: {data: {user: {...}}} OR {user: {...}}
        Map<String, dynamic> userJson;
        if (bodyMap.containsKey('data') && bodyMap['data'] is Map) {
          final Map<String, dynamic> data =
              bodyMap['data'] as Map<String, dynamic>;
          userJson = data['user'] as Map<String, dynamic>;
        } else if (bodyMap.containsKey('user') && bodyMap['user'] is Map) {
          userJson = bodyMap['user'] as Map<String, dynamic>;
        } else {
          // Fallback: the whole body might be user data
          userJson = bodyMap;
        }

        print('GetProfileUseCase: userJson=$userJson');
        return UserModel.fromJson(userJson);
      } catch (e) {
        print('Error parsing GetProfile data: $e');
      }
    }

    return null;
  }
}
