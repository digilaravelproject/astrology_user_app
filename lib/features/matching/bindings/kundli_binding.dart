import 'package:get/get.dart';
import '../controllers/kundli_controller.dart';
import '../data/repositories/kundli_repository_impl.dart';
import '../domain/repositories/kundli_repository.dart';
import '../domain/usecases/get_birth_chart_usecase.dart';

class KundliBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<KundliRepository>(
      () => KundliRepositoryImpl(),
    );

    // UseCase
    Get.lazyPut<GetBirthChartUseCase>(
      () => GetBirthChartUseCase(
        repository: Get.find<KundliRepository>(),
      ),
    );

    // Controller
    Get.lazyPut<KundliController>(
      () => KundliController(
        getBirthChartUseCase: Get.find<GetBirthChartUseCase>(),
      ),
    );
  }
}
