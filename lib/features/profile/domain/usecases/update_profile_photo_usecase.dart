import 'package:image_picker/image_picker.dart';
import 'package:astro_user/features/auth/data/models/user_model.dart';
import 'package:astro_user/features/profile/data/datasources/profile_service.dart';

class UpdateProfilePhotoUseCase {
  final ProfileService _profileService;

  UpdateProfilePhotoUseCase(this._profileService);

  Future<UserModel?> execute(XFile imageFile) async {
    final response = await _profileService.updateProfilePhoto(imageFile);

    if (response.isSuccess && response.body != null) {
      try {
        final Map<String, dynamic> bodyMap = response.body as Map<String, dynamic>;
        
        // Handling variations where user details might be within 'user' nested object or not
        final Map<String, dynamic> userJson = bodyMap.containsKey('user') ? bodyMap['user'] : bodyMap;
        return UserModel.fromJson(userJson);
      } catch (e) {
        print('Error parsing UpdateProfilePhoto data: $e');
      }
    }

    return null;
  }
}
