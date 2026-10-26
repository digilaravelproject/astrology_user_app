import 'package:get/get.dart';
import 'package:astro_user/features/home/data/models/remedy_model.dart';
import 'package:astro_user/features/home/domain/usecases/get_remedies_usecase.dart';
import 'package:astro_user/features/home/domain/usecases/get_remedy_by_id_usecase.dart';

class RemedyController extends GetxController {
  final GetRemediesUseCase _getRemediesUseCase;
  final GetRemedyByIdUseCase _getRemedyByIdUseCase;

  static const List<String> remedyImages = [
    'https://cdn-icons-png.flaticon.com/512/2917/2917995.png',
    'https://cdn-icons-png.flaticon.com/512/2917/2917999.png',
    'https://cdn-icons-png.flaticon.com/512/3094/3094673.png',
    'https://cdn-icons-png.flaticon.com/512/3094/3094679.png',
  ];

  RemedyController({
    required GetRemediesUseCase getRemediesUseCase,
    required GetRemedyByIdUseCase getRemedyByIdUseCase,
  })  : _getRemediesUseCase = getRemediesUseCase,
        _getRemedyByIdUseCase = getRemedyByIdUseCase;

  String getRemedyImage(int index) {
    return remedyImages[index % remedyImages.length];
  }

  final isLoading = false.obs;
  final remedies = <RemedyModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRemedies();
  }

  Future<void> fetchRemedies() async {
    try {
      isLoading.value = true;
      final result = await _getRemediesUseCase.execute();
      remedies.assignAll(result);
    } catch (e) {
      print('Error fetching remedies: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<RemedyModel?> fetchRemedyById(int id) async {
    try {
      return await _getRemedyByIdUseCase.execute(id);
    } catch (e) {
      print('Error fetching remedy detail: $e');
      return null;
    }
  }
}
