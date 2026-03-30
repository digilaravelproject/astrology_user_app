import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../../../core/services/network/response_model.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/domain/services/auth_service.dart';
import '../domain/usecases/get_plan_by_id_usecase.dart';
import '../domain/usecases/update_profile_photo_usecase.dart';
import '../domain/usecases/get_profile_usecase.dart';
import '../domain/usecases/update_profile_in_app_usecase.dart';
import '../domain/usecases/get_following_usecase.dart';
import '../domain/usecases/get_plans_usecase.dart';
import '../domain/usecases/upgrade_plan_usecase.dart';
import '../domain/usecases/verify_upgrade_usecase.dart';
import '../domain/models/plan_model.dart';
import '../../../../features/auth/domain/models/user_model.dart';

class ProfileController extends GetxController {
  final UpdateProfilePhotoUseCase _updateProfilePhotoUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileInAppUseCase _updateProfileInAppUseCase;
  final GetFollowingUseCase _getFollowingUseCase;
  final GetPlansUseCase _getPlansUseCase;
  final GetPlanByIdUseCase _getPlanByIdUseCase;
  final UpgradePlanUseCase _upgradePlanUseCase;
  final VerifyUpgradeUseCase _verifyUpgradeUseCase;

  ProfileController({
    required UpdateProfilePhotoUseCase updateProfilePhotoUseCase,
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileInAppUseCase updateProfileInAppUseCase,
    required GetFollowingUseCase getFollowingUseCase,
    required GetPlansUseCase getPlansUseCase,
    required GetPlanByIdUseCase getPlanByIdUseCase,
    required UpgradePlanUseCase upgradePlanUseCase,
    required VerifyUpgradeUseCase verifyUpgradeUseCase,
  })
      : _updateProfilePhotoUseCase = updateProfilePhotoUseCase,
        _getProfileUseCase = getProfileUseCase,
        _updateProfileInAppUseCase = updateProfileInAppUseCase,
        _getFollowingUseCase = getFollowingUseCase,
        _getPlansUseCase = getPlansUseCase,
        _getPlanByIdUseCase = getPlanByIdUseCase,
        _upgradePlanUseCase = upgradePlanUseCase,
        _verifyUpgradeUseCase = verifyUpgradeUseCase;

  final isLoading = false.obs;
  final RxList<dynamic> followingList = <dynamic>[].obs;
  final RxList<PlanModel> plans = <PlanModel>[].obs;
  final Rx<PlanModel?> selectedPlan = Rx<PlanModel?>(null);
  PlanModel? activePlan;

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
    print('_syncUser: planId=${updatedUser.planId}, isMatrimony=${updatedUser.isMatrimony}');
    authController.currentUser.value = updatedUser;
    await Get.find<AuthService>().saveUserInfo(updatedUser);
    
    // Store user data in SharedPreferences
    SharedPrefs.setInt('user_id', updatedUser.id);
    SharedPrefs.setString('user_name', updatedUser.name);
    SharedPrefs.setString('user_mobile', updatedUser.mobile);
    SharedPrefs.setBool('profile_completed', updatedUser.profileCompleted);
    SharedPrefs.setBool('is_matrimony', updatedUser.isMatrimony);
    if (updatedUser.planId != null) {
      SharedPrefs.setInt('plan_id', updatedUser.planId!);
    }
    if (updatedUser.planStartedAt != null) {
      SharedPrefs.setString('plan_started_at', updatedUser.planStartedAt!);
    }
    if (updatedUser.planExpiresAt != null) {
      SharedPrefs.setString('plan_expires_at', updatedUser.planExpiresAt!);
    }
  }

  Future<void> fetchFollowing() async {
    try {
      isLoading.value = true;
      final result = await _getFollowingUseCase.execute();
      if (result.isSuccess && result.body != null) {
        final data = result.body as Map<String, dynamic>;
        final following = data['following'] ?? [];
        followingList.assignAll(following);
      }
    } catch (e) {
      print('Error fetching following: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPlans() async {
    try {
      isLoading.value = true;
      final result = await _getPlansUseCase.execute();
      if (result.isSuccess && result.body != null) {
        final data = result.body as Map<String, dynamic>;
        final plansList = data['plans'] as List?;
        if (plansList != null) {
          plans.assignAll(plansList.map((e) =>
              PlanModel.fromJson(e as Map<String, dynamic>)).toList());
        }
        activePlan = data['active_plan'] != null ? PlanModel.fromJson(
            data['active_plan'] as Map<String, dynamic>) : null;
      }
    } catch (e) {
      print('Error fetching plans: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPlanById(int id) async {
    try {
      isLoading.value = true;
      final result = await _getPlanByIdUseCase.execute(id);
      if (result.isSuccess && result.body != null) {
        final data = result.body as Map<String, dynamic>;
        // The plan data is inside the 'data' field
        if (data.containsKey('data')) {
          selectedPlan.value =
              PlanModel.fromJson(data['data'] as Map<String, dynamic>);
        } else {
          selectedPlan.value = PlanModel.fromJson(data);
        }
      }
    } catch (e) {
      print('Error fetching plan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    try {
      isLoading.value = true;
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id ?? 0;
      final updatedUser = await _getProfileUseCase.execute(userId);
      if (updatedUser != null) {
        await _syncUser(updatedUser);
      }
    } catch (e) {
      print('Error refreshing profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<ResponseModel> upgradePlan(int planId) async {
    try {
      isLoading.value = true;
      final result = await _upgradePlanUseCase.execute(planId);
      return result;
    } catch (e) {
      print('Error upgrading plan: $e');
      return ResponseModel(
          isSuccess: false, message: e.toString(), statusCode: 500);
    } finally {
      isLoading.value = false;
    }
  }

  Future<ResponseModel> verifyUpgrade({
    required String providerOrderId,
    required String providerPaymentId,
    required String signature,
  }) async {
    try {
      isLoading.value = true;
      final result = await _verifyUpgradeUseCase.execute(
        providerOrderId: providerOrderId,
        providerPaymentId: providerPaymentId,
        signature: signature,
      );
      
      // Refresh profile after successful upgrade
      if (result.isSuccess) {
        await refreshProfile();
      }
      
      return result;
    } catch (e) {
      print('Error verifying upgrade: $e');
      return ResponseModel(
          isSuccess: false, message: e.toString(), statusCode: 500);
    } finally {
      isLoading.value = false;
    }
  }
}