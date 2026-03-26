import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../domain/repositories/matrimony_repository.dart';
import '../domain/services/matrimony_service.dart';
import '../domain/usecases/save_matrimony_profile_usecase.dart';
import '../controllers/matrimony_controller.dart';

class MatrimonyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MatrimonyRepositoryInterface>(() => MatrimonyRepository(apiClient: Get.find()));
    Get.lazyPut<MatrimonyServiceInterface>(() => MatrimonyService(repository: Get.find()));
    Get.lazyPut(() => SaveMatrimonyProfileUseCase(service: Get.find()));
    Get.lazyPut(() => MatrimonyController(saveMatrimonyProfileUseCase: Get.find()));
  }
}
