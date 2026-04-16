import 'package:get/get.dart';
import '../data/models/kundli_request_model.dart';
import '../data/models/kundli_response_model.dart';
import '../domain/usecases/get_birth_chart_usecase.dart';

class KundliController extends GetxController {
  final GetBirthChartUseCase getBirthChartUseCase;

  KundliController({required this.getBirthChartUseCase});

  final Rx<KundliResponseModel?> kundliData = Rx<KundliResponseModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch default kundli data
    fetchKundliData();
  }

  Future<void> fetchKundliData({
    String? birthDate,
    String? birthTime,
    double? latitude,
    double? longitude,
    String? datetime,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Default values for testing
      final request = KundliRequestModel(
        birthDate: birthDate ?? '1995-08-15',
        birthTime: birthTime ?? '10:30',
        latitude: latitude ?? 28.6139,
        longitude: longitude ?? 77.2090,
        datetime: datetime ?? '1990-01-15T14:30:00',
      );

      print('[KUNDLI_APP] [DEBUG] Controller: Fetching kundli data');
      final result = await getBirthChartUseCase.call(request);
      
      kundliData.value = result;
      print('[KUNDLI_APP] [DEBUG] Controller: Kundli data set successfully');
    } catch (e) {
      print('[KUNDLI_APP] [ERROR] Controller: Failed to load kundli: $e');
      errorMessage.value = 'Failed to load kundli data: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get planets grouped by house for chart display
  Map<int, List<String>> getPlanetsGroupedByHouse() {
    if (kundliData.value == null) return {};
    
    final Map<int, List<String>> grouped = {};
    for (var planet in kundliData.value!.data.planets) {
      if (!grouped.containsKey(planet.house)) {
        grouped[planet.house] = [];
      }
      grouped[planet.house]!.add(planet.shortName);
    }
    return grouped;
  }

  // Get current mahadasha info
  String getCurrentMahadashaInfo() {
    if (kundliData.value == null) return '';
    final current = kundliData.value!.data.dashas.current;
    return '${current.mahadasha} - ${current.antardasha}';
  }

  // Get yogas present
  List<Yoga> getPresentYogas() {
    if (kundliData.value == null) return [];
    return kundliData.value!.data.yogas.where((y) => y.present).toList();
  }
}
