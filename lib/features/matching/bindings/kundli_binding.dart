import 'package:get/get.dart';
import '../controllers/kundli_controller.dart';
import '../controllers/matching_controller.dart';
import '../data/repositories/kundli_repository_impl.dart';
import '../data/repositories/matching_repository_impl.dart';
import '../domain/repositories/kundli_repository.dart';
import '../domain/repositories/matching_repository.dart';
import '../domain/usecases/get_birth_chart_usecase.dart';
import '../domain/usecases/get_matching_usecase.dart';

class KundliBinding extends Bindings {
  @override
  void dependencies() {
    // Kundli Repository
    Get.lazyPut<KundliRepository>(
      () => KundliRepositoryImpl(),
    );

    // Kundli UseCase
    Get.lazyPut<GetBirthChartUseCase>(
      () => GetBirthChartUseCase(
        repository: Get.find<KundliRepository>(),
      ),
    );

    // Kundli Controller
    Get.lazyPut<KundliController>(
      () => KundliController(
        getBirthChartUseCase: Get.find<GetBirthChartUseCase>(),
      ),
    );

    // Matching Repository
    Get.lazyPut<MatchingRepository>(
      () => MatchingRepositoryImpl(),
    );

    // Matching UseCase
    Get.lazyPut<GetMatchingUseCase>(
      () => GetMatchingUseCase(
        repository: Get.find<MatchingRepository>(),
      ),
    );

    // Matching Controller
    Get.lazyPut<MatchingController>(
      () => MatchingController(
        getMatchingUseCase: Get.find<GetMatchingUseCase>(),
      ),
    );
  }
}
