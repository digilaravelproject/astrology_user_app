import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../domain/repositories/matrimony_repository.dart';
import '../domain/services/matrimony_service.dart';
import '../domain/usecases/get_matrimony_profile_usecase.dart';
import '../domain/usecases/save_matrimony_profile_usecase.dart';
import '../domain/usecases/update_matrimony_profile_usecase.dart';
import '../domain/usecases/get_matrimony_profile_details_usecase.dart';
import '../domain/usecases/get_my_matrimony_profile_details_usecase.dart';
import '../domain/usecases/search_matrimony_profiles_usecase.dart';
import '../domain/usecases/block_matrimony_profile_usecase.dart';
import '../domain/usecases/report_matrimony_profile_usecase.dart';
import '../controllers/matrimony_controller.dart';
import '../../profile/domain/usecases/get_profile_usecase.dart';
import '../../profile/domain/repositories/profile_repository.dart';
import '../../profile/domain/services/profile_service.dart';

class MatrimonyBinding extends Bindings {
  @override
  void dependencies() {
    // Profile Dependencies (Shared)
    Get.lazyPut(() => ProfileRepository(Get.find<ApiClient>()));
    Get.lazyPut(() => ProfileService(Get.find<ProfileRepository>()));
    Get.lazyPut(() => GetProfileUseCase(Get.find<ProfileService>()));

    Get.lazyPut<MatrimonyRepositoryInterface>(() => MatrimonyRepository(apiClient: Get.find()));
    Get.lazyPut<MatrimonyServiceInterface>(() => MatrimonyService(repository: Get.find()));
    Get.lazyPut(() => SaveMatrimonyProfileUseCase(service: Get.find()));
    Get.lazyPut(() => UpdateMatrimonyProfileUseCase(service: Get.find()));
    Get.lazyPut(() => GetMatrimonyProfileUseCase(service: Get.find()));
    Get.lazyPut(() => GetMatrimonyProfileDetailsUseCase(Get.find<MatrimonyServiceInterface>()));
    Get.lazyPut(() => GetMyMatrimonyProfileDetailsUseCase(Get.find<MatrimonyServiceInterface>()));
    Get.lazyPut(() => SearchMatrimonyProfilesUseCase(Get.find<MatrimonyServiceInterface>()));
    Get.lazyPut(() => BlockMatrimonyProfileUseCase(service: Get.find<MatrimonyServiceInterface>()));
    Get.lazyPut(() => ReportMatrimonyProfileUseCase(service: Get.find<MatrimonyServiceInterface>()));
    
    Get.lazyPut(() => MatrimonyController(
      saveMatrimonyProfileUseCase: Get.find<SaveMatrimonyProfileUseCase>(),
      updateMatrimonyProfileUseCase: Get.find<UpdateMatrimonyProfileUseCase>(),
      getMatrimonyProfileUseCase: Get.find<GetMatrimonyProfileUseCase>(),
      getMatrimonyProfileDetailsUseCase: Get.find<GetMatrimonyProfileDetailsUseCase>(),
      getMyMatrimonyProfileDetailsUseCase: Get.find<GetMyMatrimonyProfileDetailsUseCase>(),
      searchMatrimonyProfilesUseCase: Get.find<SearchMatrimonyProfilesUseCase>(),
      blockMatrimonyProfileUseCase: Get.find<BlockMatrimonyProfileUseCase>(),
      reportMatrimonyProfileUseCase: Get.find<ReportMatrimonyProfileUseCase>(),
      getProfileUseCase: Get.find<GetProfileUseCase>(),
    ));
  }
}


