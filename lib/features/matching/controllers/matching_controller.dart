import 'package:get/get.dart';
import '../data/models/matching_request_model.dart';
import '../data/models/matching_response_model.dart';
import '../domain/usecases/get_matching_usecase.dart';

class MatchingController extends GetxController {
  final GetMatchingUseCase getMatchingUseCase;

  MatchingController({required this.getMatchingUseCase});

  final Rx<MatchingResponseModel?> matchingData = Rx<MatchingResponseModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> fetchMatchingData({
    required String boyDob,
    required String boyTob,
    required String girlDob,
    required String girlTob,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('[MATCHING_APP] [DEBUG] Controller: Fetching matching data');
      print('[MATCHING_APP] [DEBUG] Boy DOB: $boyDob, TOB: $boyTob');
      print('[MATCHING_APP] [DEBUG] Girl DOB: $girlDob, TOB: $girlTob');

      // Static lat/lng for now (New Delhi and Mumbai)
      final request = MatchingRequestModel(
        boy: PersonDetails(
          dateOfBirth: boyDob,
          timeOfBirth: boyTob,
          latitude: 28.6139,
          longitude: 77.2090,
        ),
        girl: PersonDetails(
          dateOfBirth: girlDob,
          timeOfBirth: girlTob,
          latitude: 19.0760,
          longitude: 72.8777,
        ),
      );

      final result = await getMatchingUseCase.call(request);
      
      matchingData.value = result;
      print('[MATCHING_APP] [DEBUG] Controller: Matching data set successfully');
      print('[MATCHING_APP] [DEBUG] Compatibility Score: ${result.data.compatibilityScore}');
    } catch (e) {
      print('[MATCHING_APP] [ERROR] Controller: Failed to load matching: $e');
      errorMessage.value = 'Failed to load matching data: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearData() {
    matchingData.value = null;
    errorMessage.value = '';
  }
}
