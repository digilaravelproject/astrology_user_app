import 'package:astro_user/core/utils/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../domain/models/matrimony_profile_model.dart';
import '../domain/usecases/get_matrimony_profile_usecase.dart';
import '../domain/usecases/save_matrimony_profile_usecase.dart';
import '../domain/usecases/update_matrimony_profile_usecase.dart';
import '../domain/usecases/get_matrimony_profile_details_usecase.dart';
import '../domain/usecases/get_my_matrimony_profile_details_usecase.dart';
import '../domain/usecases/search_matrimony_profiles_usecase.dart';
import '../domain/usecases/block_matrimony_profile_usecase.dart';
import '../domain/usecases/report_matrimony_profile_usecase.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/domain/services/auth_service.dart';
import '../../profile/domain/usecases/get_profile_usecase.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../auth/domain/models/user_model.dart';

class MatrimonyController extends GetxController {
  final SaveMatrimonyProfileUseCase _saveMatrimonyProfileUseCase;
  final UpdateMatrimonyProfileUseCase _updateMatrimonyProfileUseCase;
  final GetMatrimonyProfileUseCase _getMatrimonyProfileUseCase;
  final GetMatrimonyProfileDetailsUseCase _getMatrimonyProfileDetailsUseCase;
  final GetMyMatrimonyProfileDetailsUseCase
  _getMyMatrimonyProfileDetailsUseCase;
  final SearchMatrimonyProfilesUseCase _searchMatrimonyProfilesUseCase;
  final BlockMatrimonyProfileUseCase _blockMatrimonyProfileUseCase;
  final ReportMatrimonyProfileUseCase _reportMatrimonyProfileUseCase;
  final GetProfileUseCase _getProfileUseCase;

  MatrimonyController({
    SaveMatrimonyProfileUseCase? saveMatrimonyProfileUseCase,
    UpdateMatrimonyProfileUseCase? updateMatrimonyProfileUseCase,
    GetMatrimonyProfileUseCase? getMatrimonyProfileUseCase,
    GetMatrimonyProfileDetailsUseCase? getMatrimonyProfileDetailsUseCase,
    GetMyMatrimonyProfileDetailsUseCase? getMyMatrimonyProfileDetailsUseCase,
    SearchMatrimonyProfilesUseCase? searchMatrimonyProfilesUseCase,
    BlockMatrimonyProfileUseCase? blockMatrimonyProfileUseCase,
    ReportMatrimonyProfileUseCase? reportMatrimonyProfileUseCase,
    GetProfileUseCase? getProfileUseCase,
  }) : _saveMatrimonyProfileUseCase =
           saveMatrimonyProfileUseCase ??
           Get.find<SaveMatrimonyProfileUseCase>(),
       _updateMatrimonyProfileUseCase =
           updateMatrimonyProfileUseCase ??
           Get.find<UpdateMatrimonyProfileUseCase>(),
       _getMatrimonyProfileUseCase =
           getMatrimonyProfileUseCase ?? Get.find<GetMatrimonyProfileUseCase>(),
       _getMatrimonyProfileDetailsUseCase =
           getMatrimonyProfileDetailsUseCase ??
           Get.find<GetMatrimonyProfileDetailsUseCase>(),
       _getMyMatrimonyProfileDetailsUseCase =
           getMyMatrimonyProfileDetailsUseCase ??
           Get.find<GetMyMatrimonyProfileDetailsUseCase>(),
       _searchMatrimonyProfilesUseCase =
           searchMatrimonyProfilesUseCase ??
           Get.find<SearchMatrimonyProfilesUseCase>(),
       _blockMatrimonyProfileUseCase =
           blockMatrimonyProfileUseCase ??
           Get.find<BlockMatrimonyProfileUseCase>(),
       _reportMatrimonyProfileUseCase =
           reportMatrimonyProfileUseCase ??
           Get.find<ReportMatrimonyProfileUseCase>(),
       _getProfileUseCase = getProfileUseCase ?? Get.find<GetProfileUseCase>();

  final RxBool isRegistered = false.obs;
  final RxBool hasPlan = false.obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  // Full profile list from API
  final RxList<MatrimonyProfileModel> allProfiles =
      <MatrimonyProfileModel>[].obs;
  // Selected profile details
  final Rxn<MatrimonyProfileModel> selectedProfile =
      Rxn<MatrimonyProfileModel>();
  // Legacy dummy list

  final RxList<Map<String, dynamic>> allCustomers =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    final authController = Get.find<AuthController>();

    // Listen for user changes to automatically update registration/plan status
    ever(authController.currentUser, (_) {
      print(
        'MatrimonyController: Auth state changed, re-checking registration status',
      );
      checkRegistrationStatus();
    });

    checkRegistrationStatus();
    getMatrimonyProfile();

    // Auto-refresh profile in background to sync any external plan purchases
    refreshRegistrationStatusFromServer();
  }

  Future<void> getMatrimonyProfile() async {
    try {
      isLoading.value = true;
      final response = await _getMatrimonyProfileUseCase.execute();
      print(
        'Matrimony Profile Response Body Type: ${response?.body.runtimeType}',
      );

      if (response != null && response.isSuccess) {
        final body = response.body;
        // ResponseModel.body is already json['data']
        final List<dynamic> profilesJson = body['profiles'] ?? [];
        print('Found ${profilesJson.length} profiles in JSON');
        allProfiles.value =
            profilesJson
                .map((json) => MatrimonyProfileModel.fromJson(json))
                .toList();
        print('Successfully parsed ${allProfiles.length} profiles into model');
      } else {
        CustomSnackbar.showError(
          response?.message ?? 'Failed to load profiles',
        );
      }
    } catch (e) {
      print('Error fetching matrimony profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getMatrimonyProfileDetails(int id) async {
    try {
      isLoading.value = true;
      selectedProfile.value = null; // Clear previous data
      final response = await _getMatrimonyProfileDetailsUseCase.execute(id);

      if (response != null && response.isSuccess) {
        final body = response.body;
        // ResponseModel.body is already json['data']
        final profileJson = body['profile'];
        if (profileJson != null) {
          selectedProfile.value = MatrimonyProfileModel.fromJson(profileJson);
          print(
            'Successfully fetched details for profile ${selectedProfile.value?.firstName}',
          );
        }
      } else {
        CustomSnackbar.showError(
          response?.message ?? 'Failed to load profile details',
        );
      }
    } catch (e) {
      print('Error fetching matrimony profile details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getMyMatrimonyProfileDetails(int userId) async {
    try {
      print(
        '[getMyMatrimonyProfileDetails] Starting API call for userId: $userId',
      );
      isLoading.value = true;
      selectedProfile.value = null; // Clear previous data

      final response = await _getMyMatrimonyProfileDetailsUseCase.execute(
        userId,
      );
      print(
        '[getMyMatrimonyProfileDetails] Response received: ${response?.isSuccess}',
      );

      if (response != null && response.isSuccess) {
        final body = response.body;
        print('[getMyMatrimonyProfileDetails] Response body: $body');

        // ResponseModel.body is already json['data']
        final profileJson = body['profile'];
        print('[getMyMatrimonyProfileDetails] Profile JSON: $profileJson');

        if (profileJson != null) {
          selectedProfile.value = MatrimonyProfileModel.fromJson(profileJson);
          print(
            '[getMyMatrimonyProfileDetails] Successfully fetched my profile: ${selectedProfile.value?.firstName}',
          );
        } else {
          print('[getMyMatrimonyProfileDetails] Profile JSON is null');
        }
      } else {
        print(
          '[getMyMatrimonyProfileDetails] API call failed: ${response?.message}',
        );
        CustomSnackbar.showError(
          response?.message ?? 'Failed to load your profile',
        );
      }
    } catch (e, stackTrace) {
      print('[getMyMatrimonyProfileDetails] Error: $e');
      print('[getMyMatrimonyProfileDetails] StackTrace: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshRegistrationStatusFromServer() async {
    try {
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;

      if (currentUser == null) return;

      print(
        'refreshRegistrationStatusFromServer: [START] Syncing status for userId=${currentUser.id}',
      );

      // 1. Fetch latest profile from server directly using UseCase
      final updatedUserFromServer = await _getProfileUseCase.execute(
        currentUser.id,
      );

      if (updatedUserFromServer != null) {
        print(
          'refreshRegistrationStatusFromServer: [SUCCESS] Fetched latest data. planId=${updatedUserFromServer.planId}',
        );

        // 2. Update Auth state
        authController.currentUser.value = updatedUserFromServer;

        // 3. Save to persistence
        await Get.find<AuthService>().saveUserInfo(updatedUserFromServer);

        // 4. Update ProfileController if it exists (to keep everything in sync)
        if (Get.isRegistered<ProfileController>()) {
          // ProfileController._syncUser is private, but updating currentUser.value
          // might be enough if ProfileController is listening.
          // Or we can just let it be since we updated the source of truth (Auth).
        }
      } else {
        print(
          'refreshRegistrationStatusFromServer: [WARNING] Failed to fetch updated profile, using existing state',
        );
      }

      // 5. Final UI refresh
      checkRegistrationStatus();
    } catch (e) {
      print('refreshRegistrationStatusFromServer: [ERROR] $e');
      checkRegistrationStatus();
    }
  }

  void checkRegistrationStatus() {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    if (user == null) {
      print(
        'checkRegistrationStatus: [FAILURE] No user found in AuthController',
      );
      isRegistered.value = false;
      return;
    }

    final isMatrimonyRegistered = user.isMatrimony;
    final userHasPlan = user.planId != null;

    print(
      'checkRegistrationStatus: [DASHBOARD] userId=${user.id}, isMatrimony=$isMatrimonyRegistered, hasPlan=$userHasPlan',
    );
    print('checkRegistrationStatus: [RAW_USER] ${user.toJsonString()}');

    // Set status flags
    isRegistered.value = isMatrimonyRegistered;
    hasPlan.value = userHasPlan;

    isRegistered.refresh();
    hasPlan.refresh();

    // Ensure persistence is updated
    SharedPrefs.setBool('isMatrimony', isMatrimonyRegistered);
    if (user.planId != null) SharedPrefs.setInt('plan_id', user.planId!);
  }

  Future<bool> saveProfile(MatrimonyProfileModel profile, XFile? photo) async {
    try {
      isLoading.value = true;
      final response = await _saveMatrimonyProfileUseCase.execute(
        profile,
        photo,
      );
      if (response.isSuccess) {
        final authController = Get.find<AuthController>();
        final currentUser = authController.currentUser.value;

        if (currentUser != null) {
          // 1. Fetch latest profile from server
          final updatedUserFromServer = await _getProfileUseCase.execute(
            currentUser.id,
          );

          if (updatedUserFromServer != null) {
            // 2. Update local state and persistence
            authController.currentUser.value = updatedUserFromServer;
            await Get.find<AuthService>().saveUserInfo(updatedUserFromServer);

            // 3. Double check and sync with ProfileController if registered
            if (Get.isRegistered<ProfileController>()) {
              await Get.find<ProfileController>().refreshProfile();
            }
          } else {
            // Fallback if profile fetch fails
            final localUpdate = currentUser.copyWith(isMatrimony: true);
            authController.currentUser.value = localUpdate;
            await Get.find<AuthService>().saveUserInfo(localUpdate);
          }
        }

        // Final sync of the registration flag
        checkRegistrationStatus();

        CustomSnackbar.showSuccess(
          response.message ?? 'Profile saved successfully',
        );
        return true;
      } else {
        CustomSnackbar.showError(response.message ?? 'Failed to save profile');
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('An unexpected error occurred');
      print('Error saving matrimony profile: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile(
    MatrimonyProfileModel profile,
    XFile? photo,
  ) async {
    try {
      isLoading.value = true;
      print(
        '[updateProfile] Starting update with profile: ${profile.firstName}',
      );

      final response = await _updateMatrimonyProfileUseCase.execute(
        profile,
        photo,
      );
      print(
        '[updateProfile] Response: ${response.isSuccess}, Message: ${response.message}',
      );

      if (response.isSuccess) {
        final authController = Get.find<AuthController>();
        final currentUser = authController.currentUser.value;

        if (currentUser != null) {
          // Fetch latest profile from server
          final updatedUserFromServer = await _getProfileUseCase.execute(
            currentUser.id,
          );

          if (updatedUserFromServer != null) {
            authController.currentUser.value = updatedUserFromServer;
            await Get.find<AuthService>().saveUserInfo(updatedUserFromServer);

            if (Get.isRegistered<ProfileController>()) {
              await Get.find<ProfileController>().refreshProfile();
            }
          }
        }

        checkRegistrationStatus();
        CustomSnackbar.showSuccess(
          response.message ?? 'Profile updated successfully',
        );
        return true;
      } else {
        CustomSnackbar.showError(
          response.message ?? 'Failed to update profile',
        );
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('An unexpected error occurred');
      print('[updateProfile] Error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _loadDummyData() {
    allCustomers.value = List.generate(
      10,
      (index) => {
        'name': index % 2 == 0 ? 'Swapna Deshmukh' : 'Riya Sharma',
        'age': index % 2 == 0 ? '27' : '29',
        'city': index % 2 == 0 ? 'Pune' : 'Mumbai',
        'state': 'Maharashtra',
        'education': 'MBA',
        'profession': 'Teacher',
        'religion': 'Hindu',
        'caste': 'Deshmukh',
        'language': 'Marathi (Mother Tongue)',
        'imageUrl':
            index % 2 == 0
                ? 'https://randomuser.me/api/portraits/women/60.jpg'
                : 'https://randomuser.me/api/portraits/women/64.jpg',
        'isMale': false,
      },
    );
  }

  // Reactive filtered list of profiles based on search query
  List<MatrimonyProfileModel> get filteredProfiles {
    if (searchQuery.value.isEmpty) {
      return allProfiles;
    }

    final query = searchQuery.value.toLowerCase();
    return allProfiles.where((p) {
      final firstName = p.firstName.toLowerCase();
      final lastName = p.lastName.toLowerCase();
      final location = p.location.toLowerCase();
      final education = p.education.toLowerCase();
      final jobTitle = p.jobTitle.toLowerCase();
      final maritalStatus = p.maritalStatus.toLowerCase();
      final gender = p.gender.toLowerCase();

      return firstName.contains(query) ||
          lastName.contains(query) ||
          location.contains(query) ||
          education.contains(query) ||
          jobTitle.contains(query) ||
          maritalStatus.contains(query) ||
          gender.contains(query);
    }).toList();
  }

  // Reactive filtered list based on search query
  List<Map<String, dynamic>> get filteredCustomers {
    if (searchQuery.value.isEmpty) {
      return allCustomers;
    }

    final query = searchQuery.value.toLowerCase();
    return allCustomers.where((c) {
      final name = c['name'].toString().toLowerCase();
      final city = c['city'].toString().toLowerCase();
      final religion = c['religion'].toString().toLowerCase();
      final caste = c['caste'].toString().toLowerCase();

      return name.contains(query) ||
          city.contains(query) ||
          religion.contains(query) ||
          caste.contains(query);
    }).toList();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  Future<void> searchMatrimonyProfiles(String query) async {
    isLoading.value = true;
    try {
      final response = await _searchMatrimonyProfilesUseCase.execute(query);
      if (response.isSuccess) {
        // ResponseModel.body is already json['data']
        final List<dynamic> profilesData = response.body['profiles'];

        allProfiles.assignAll(
          profilesData
              .map((json) => MatrimonyProfileModel.fromJson(json))
              .toList(),
        );
      } else {
        CustomSnackbar.showError('Failed to search profiles');
      }
    } catch (e) {
      print('searchMatrimonyProfiles error: $e');
      CustomSnackbar.showError('An error occurred during search');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> blockProfile(int id) async {
    try {
      isLoading.value = true;
      final response = await _blockMatrimonyProfileUseCase.execute(id);
      if (response != null && response.isSuccess) {
        CustomSnackbar.showSuccess(response.message);
        // Refresh details
        await getMatrimonyProfileDetails(id);
        // Refresh list
        getMatrimonyProfile();
      } else {
        CustomSnackbar.showError(
          response?.message ?? 'Failed to block profile',
        );
      }
    } catch (e) {
      CustomSnackbar.showError('Error blocking profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> unblockProfile(int id) async {
    try {
      isLoading.value = true;
      final response = await _blockMatrimonyProfileUseCase.execute(id);
      if (response != null && response.isSuccess) {
        CustomSnackbar.showSuccess(response.message);
        // Refresh details
        await getMatrimonyProfileDetails(id);
        // Refresh list
        getMatrimonyProfile();
      } else {
        CustomSnackbar.showError(
          response?.message ?? 'Failed to unblock profile',
        );
      }
    } catch (e) {
      CustomSnackbar.showError('Error unblocking profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reportProfile(int id, String reason) async {
    try {
      isLoading.value = true;
      final response = await _reportMatrimonyProfileUseCase.execute(id, reason);
      if (response.isSuccess) {
        CustomSnackbar.showSuccess(
          response.message ?? 'Profile reported successfully',
        );
        Get.back(); // Close bottom sheet
      } else {
        CustomSnackbar.showError(
          response.message ?? 'Failed to report profile',
        );
      }
    } catch (e) {
      print('reportProfile error: $e');
      CustomSnackbar.showError('An error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  void setRegistered(bool value) {
    print('setRegistered: setting isRegistered to $value');
    isRegistered.value = value;
    isRegistered.refresh();
  }
}
