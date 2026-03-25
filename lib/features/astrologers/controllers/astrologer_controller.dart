import 'package:get/get.dart';
import '../domain/models/astrologer_model.dart';
import '../domain/usecases/get_astrologers_usecase.dart';

class AstrologerController extends GetxController {
  final GetAstrologersUseCase _getAstrologersUseCase;

  AstrologerController({required GetAstrologersUseCase getAstrologersUseCase})
      : _getAstrologersUseCase = getAstrologersUseCase;

  final RxList<AstrologerModel> astrologers = <AstrologerModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAstrologers();
  }

  Future<void> fetchAstrologers() async {
    try {
      isLoading.value = true;
      final result = await _getAstrologersUseCase.execute();
      astrologers.assignAll(result);
    } catch (e) {
      print('Error fetching astrologers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Filtered astrologers based on search query
  List<AstrologerModel> getFilteredAstrologers(String query) {
    if (query.isEmpty) return astrologers;
    return astrologers
        .where((a) => a.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
