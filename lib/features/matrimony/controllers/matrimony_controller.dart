import 'package:astro_user/core/utils/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../domain/models/matrimony_profile_model.dart';
import '../domain/usecases/get_matrimony_profile_usecase.dart';
import '../domain/usecases/save_matrimony_profile_usecase.dart';
import '../domain/usecases/get_matrimony_profile_details_usecase.dart';
import '../domain/usecases/search_matrimony_profiles_usecase.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/domain/services/auth_service.dart';
import '../../profile/domain/usecases/get_profile_usecase.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../auth/domain/models/user_model.dart';

class MatrimonyController extends GetxController {
  final SaveMatrimonyProfileUseCase _saveMatrimonyProfileUseCase;
  final GetMatrimonyProfileUseCase _getMatrimonyProfileUseCase;
  final GetMatrimonyProfileDetailsUseCase _getMatrimonyProfileDetailsUseCase;
  final SearchMatrimonyProfilesUseCase _searchMatrimonyProfilesUseCase;
  final GetProfileUseCase _getProfileUseCase;

  MatrimonyController({
    SaveMatrimonyProfileUseCase? saveMatrimonyProfileUseCase,
    GetMatrimonyProfileUseCase? getMatrimonyProfileUseCase,
    GetMatrimonyProfileDetailsUseCase? getMatrimonyProfileDetailsUseCase,
    SearchMatrimonyProfilesUseCase? searchMatrimonyProfilesUseCase,
    GetProfileUseCase? getProfileUseCase,
  })  : _saveMatrimonyProfileUseCase = saveMatrimonyProfileUseCase ?? Get.find<SaveMatrimonyProfileUseCase>(),
        _getMatrimonyProfileUseCase = getMatrimonyProfileUseCase ?? Get.find<GetMatrimonyProfileUseCase>(),
        _getMatrimonyProfileDetailsUseCase = getMatrimonyProfileDetailsUseCase ?? Get.find<GetMatrimonyProfileDetailsUseCase>(),
        _searchMatrimonyProfilesUseCase = searchMatrimonyProfilesUseCase ?? Get.find<SearchMatrimonyProfilesUseCase>(),
        _getProfileUseCase = getProfileUseCase ?? Get.find<GetProfileUseCase>();



  final RxBool isRegistered = false.obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  // Full profile list from API
  final RxList<MatrimonyProfileModel> allProfiles = <MatrimonyProfileModel>[].obs;
  // Selected profile details
  final Rxn<MatrimonyProfileModel> selectedProfile = Rxn<MatrimonyProfileModel>();
  // Legacy dummy list

  final RxList<Map<String, dynamic>> allCustomers = <Map<String, dynamic>>[].obs;


  @override
  void onInit() {
    super.onInit();
    // _loadDummyData();
    checkRegistrationStatus();
    getMatrimonyProfile();

  }

  Future<void> getMatrimonyProfile() async {
    try {
      isLoading.value = true;
      final response = await _getMatrimonyProfileUseCase.execute();
      print('Matrimony Profile Response Body Type: ${response?.body.runtimeType}');
      
      if (response != null && response.isSuccess) {
        final body = response.body;
        // ResponseModel.body is already json['data']
        final List<dynamic> profilesJson = body['profiles'] ?? [];
        print('Found ${profilesJson.length} profiles in JSON');
        allProfiles.value = profilesJson.map((json) => MatrimonyProfileModel.fromJson(json)).toList();
        print('Successfully parsed ${allProfiles.length} profiles into model');
      } else {
        CustomSnackbar.showError(response?.message ?? 'Failed to load profiles');
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
          print('Successfully fetched details for profile ${selectedProfile.value?.firstName}');
        }
      } else {
        CustomSnackbar.showError(response?.message ?? 'Failed to load profile details');
      }

    } catch (e) {
      print('Error fetching matrimony profile details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshRegistrationStatusFromServer() async {
    try {
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id;
      print('refreshRegistrationStatusFromServer: [START] Syncing status for userId=$userId');

      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        await profileController.refreshProfile();
        print('refreshRegistrationStatusFromServer: [SUCCESS] Profile refreshed via ProfileController');
      } else {
        print('refreshRegistrationStatusFromServer: [WARNING] ProfileController not found, using existing Auth state');
      }
      
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
      print('checkRegistrationStatus: [FAILURE] No user found in AuthController');
      isRegistered.value = false;
      return;
    }
    
    final isMatrimonyRegistered = user.isMatrimony;
    print('checkRegistrationStatus: [DASHBOARD] userId=${user.id}, isMatrimony=$isMatrimonyRegistered');
    print('checkRegistrationStatus: [RAW_USER] ${user.toJsonString()}');
    
    // Set isRegistered based on isMatrimony flag from user profile
    isRegistered.value = isMatrimonyRegistered;
    isRegistered.refresh();
    
    // Ensure persistence is updated
    SharedPrefs.setBool('isMatrimony', isMatrimonyRegistered);
    if (user.planId != null) SharedPrefs.setInt('plan_id', user.planId!);
  }


  Future<bool> saveProfile(MatrimonyProfileModel profile, XFile? photo) async {
    try {
      isLoading.value = true;
      final response = await _saveMatrimonyProfileUseCase.execute(profile, photo);
      if (response.isSuccess) {
        final authController = Get.find<AuthController>();
        final currentUser = authController.currentUser.value;
        
        if (currentUser != null) {
          // 1. Fetch latest profile from server
          final updatedUserFromServer = await _getProfileUseCase.execute(currentUser.id);
          
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
        
        CustomSnackbar.showSuccess(response.message ?? 'Profile saved successfully');
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

  void _loadDummyData() {
    allCustomers.value = List.generate(10, (index) => {
      'name': index % 2 == 0 ? 'Swapna Deshmukh' : 'Riya Sharma',
      'age': index % 2 == 0 ? '27' : '29',
      'city': index % 2 == 0 ? 'Pune' : 'Mumbai',
      'state': 'Maharashtra',
      'education': 'MBA',
      'profession': 'Teacher',
      'religion': 'Hindu',
      'caste': 'Deshmukh',
      'language': 'Marathi (Mother Tongue)',
      'imageUrl': index % 2 == 0 ? 'https://randomuser.me/api/portraits/women/60.jpg' : 'https://randomuser.me/api/portraits/women/64.jpg',
      'isMale': false,
    });
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
          profilesData.map((json) => MatrimonyProfileModel.fromJson(json)).toList(),
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


  void setRegistered(bool value) {
    print('setRegistered: setting isRegistered to $value');
    isRegistered.value = value;
    isRegistered.refresh();
  }
}
