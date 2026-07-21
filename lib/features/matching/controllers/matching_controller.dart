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
    required double boyLat,
    required double boyLng,
    required String boyTz,
    required String girlDob,
    required String girlTob,
    required double girlLat,
    required double girlLng,
    required String girlTz,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('[MATCHING_APP] [DEBUG] Controller: Fetching matching data');
      print('[MATCHING_APP] [DEBUG] Boy DOB: $boyDob, TOB: $boyTob, Lat: $boyLat, Lng: $boyLng, TZ: $boyTz');
      print('[MATCHING_APP] [DEBUG] Girl DOB: $girlDob, TOB: $girlTob, Lat: $girlLat, Lng: $girlLng, TZ: $girlTz');

      // Build ISO datetime strings: "2001-07-21T04:52:00"
      final maleDatetime = "${boyDob}T$boyTob";
      final femaleDatetime = "${girlDob}T$girlTob";

      final request = MatchingRequestModel(
        male: PersonDetails(
          datetime: maleDatetime,
          latitude: boyLat,
          longitude: boyLng,
          timezone: boyTz,
        ),
        female: PersonDetails(
          datetime: femaleDatetime,
          latitude: girlLat,
          longitude: girlLng,
          timezone: girlTz,
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
