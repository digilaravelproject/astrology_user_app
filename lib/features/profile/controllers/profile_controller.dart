import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/domain/services/auth_service.dart';
import '../domain/usecases/update_profile_photo_usecase.dart';
import '../domain/usecases/get_profile_usecase.dart';
import '../domain/usecases/update_profile_in_app_usecase.dart';
import '../../../../features/auth/domain/models/user_model.dart';

class ProfileController extends GetxController {
  final UpdateProfilePhotoUseCase _updateProfilePhotoUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileInAppUseCase _updateProfileInAppUseCase;

  ProfileController({
    required UpdateProfilePhotoUseCase updateProfilePhotoUseCase,
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileInAppUseCase updateProfileInAppUseCase,
  })  : _updateProfilePhotoUseCase = updateProfilePhotoUseCase,
        _getProfileUseCase = getProfileUseCase,
        _updateProfileInAppUseCase = updateProfileInAppUseCase;

  final isLoading = false.obs;

  Future<UserModel?> getProfileData(int id) async {
    try {
      isLoading.value = true;
      final user = await _getProfileUseCase.execute(id);
      return user;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfilePhoto(XFile imageFile) async {
    try {
      isLoading.value = true;
      final updatedUser = await _updateProfilePhotoUseCase.execute(imageFile);

      if (updatedUser != null) {
        await _syncUser(updatedUser);
        CustomSnackbar.showSuccess('Profile photo updated successfully');
      } else {
        CustomSnackbar.showError('Failed to update profile photo');
      }
    } catch (e) {
      CustomSnackbar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfileInApp(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final updatedUser = await _updateProfileInAppUseCase.execute(data);

      if (updatedUser != null) {
        await _syncUser(updatedUser);
        Get.back();
        CustomSnackbar.showSuccess('Profile updated successfully');
        return true;
      } else {
        CustomSnackbar.showError('Failed to update profile');
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _syncUser(UserModel updatedUser) async {
    final authController = Get.find<AuthController>();
    authController.currentUser.value = updatedUser;
    await Get.find<AuthService>().saveUserInfo(updatedUser);
  }
}
