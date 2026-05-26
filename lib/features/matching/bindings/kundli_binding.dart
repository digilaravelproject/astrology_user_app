import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../controllers/kundli_controller.dart';
import '../controllers/matching_controller.dart';
import '../data/repositories/kundli_repository_impl.dart';
import '../data/repositories/matching_repository_impl.dart';
import '../domain/repositories/kundli_repository.dart';
import '../domain/repositories/matching_repository.dart';
import '../domain/usecases/get_birth_chart_usecase.dart';
import '../domain/usecases/create_kundli_usecase.dart';
import '../domain/usecases/get_kundli_list_usecase.dart';
import '../domain/usecases/get_kundli_by_id_usecase.dart';
import '../domain/usecases/update_kundli_usecase.dart';
import '../domain/usecases/delete_kundli_usecase.dart';
import '../domain/usecases/get_matching_usecase.dart';

class KundliBinding extends Bindings {
  @override
  void dependencies() {
    // Kundli Repository
    Get.lazyPut<KundliRepository>(
      () => KundliRepositoryImpl(apiClient: Get.find<ApiClient>()),
    );

    // Kundli UseCases
    Get.lazyPut<GetBirthChartUseCase>(
      () => GetBirthChartUseCase(
        repository: Get.find<KundliRepository>(),
      ),
    );

    Get.lazyPut<CreateKundliUseCase>(
      () => CreateKundliUseCase(
        repository: Get.find<KundliRepository>(),
      ),
    );

    Get.lazyPut<GetKundliListUseCase>(
      () => GetKundliListUseCase(
        repository: Get.find<KundliRepository>(),
      ),
    );

    Get.lazyPut<GetKundliByIdUseCase>(
      () => GetKundliByIdUseCase(
        repository: Get.find<KundliRepository>(),
      ),
    );

    Get.lazyPut<UpdateKundliUseCase>(
      () => UpdateKundliUseCase(
        repository: Get.find<KundliRepository>(),
      ),
    );

    Get.lazyPut<DeleteKundliUseCase>(
      () => DeleteKundliUseCase(
        repository: Get.find<KundliRepository>(),
      ),
    );

    // Kundli Controller
    Get.lazyPut<KundliController>(
      () => KundliController(
        getBirthChartUseCase: Get.find<GetBirthChartUseCase>(),
        createKundliUseCase: Get.find<CreateKundliUseCase>(),
        getKundliListUseCase: Get.find<GetKundliListUseCase>(),
        getKundliByIdUseCase: Get.find<GetKundliByIdUseCase>(),
        updateKundliUseCase: Get.find<UpdateKundliUseCase>(),
        deleteKundliUseCase: Get.find<DeleteKundliUseCase>(),
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
