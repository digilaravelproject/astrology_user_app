import 'package:get/get.dart';
import '../domain/models/founder_model.dart';
import '../domain/usecases/get_founder_words_usecase.dart';

class FounderController extends GetxController {
  final GetFounderWordsUseCase _getFounderWordsUseCase;

  FounderController({required GetFounderWordsUseCase getFounderWordsUseCase})
      : _getFounderWordsUseCase = getFounderWordsUseCase;

  final isLoading = false.obs;
  final founderWords = <FounderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchFounderWords();
  }

  Future<void> fetchFounderWords() async {
    try {
      isLoading.value = true;
      final result = await _getFounderWordsUseCase.execute();
      founderWords.assignAll(result);
    } catch (e) {
      print('Error fetching founder words: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
