import 'package:astro_user/core/utils/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../domain/models/matrimony_profile_model.dart';
import '../domain/usecases/save_matrimony_profile_usecase.dart';

class MatrimonyController extends GetxController {
  final SaveMatrimonyProfileUseCase _saveMatrimonyProfileUseCase;

  MatrimonyController({required SaveMatrimonyProfileUseCase saveMatrimonyProfileUseCase})
      : _saveMatrimonyProfileUseCase = saveMatrimonyProfileUseCase;

  final RxBool isRegistered = false.obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  // Full customer list
  final RxList<Map<String, dynamic>> allCustomers = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  Future<bool> saveProfile(MatrimonyProfileModel profile, XFile? photo) async {
    try {
      isLoading.value = true;
      final response = await _saveMatrimonyProfileUseCase.execute(profile, photo);
      if (response.isSuccess) {
        isRegistered.value = true;
        CustomSnackbar.showSuccess(response.message ?? 'Profile saved successfully');
        return true;
      } else {
        CustomSnackbar.showError(response.message ?? 'Failed to save profile');
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('An unexpected error occurred');
      //Get.snackbar('Error', 'An unexpected error occurred');
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

  void setRegistered(bool value) {
    isRegistered.value = value;
  }
}
