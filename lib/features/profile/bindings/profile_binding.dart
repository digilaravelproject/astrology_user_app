import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../controllers/profile_controller.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/services/profile_service.dart';
import '../domain/usecases/get_plan_by_id_usecase.dart';
import '../domain/usecases/update_profile_photo_usecase.dart';
import '../domain/usecases/get_profile_usecase.dart';
import '../domain/usecases/update_profile_in_app_usecase.dart';
import '../domain/usecases/get_following_usecase.dart';
import '../domain/usecases/get_plans_usecase.dart';
import '../domain/usecases/upgrade_plan_usecase.dart';
import '../domain/usecases/verify_upgrade_usecase.dart';
import '../domain/repositories/plan_repository.dart';
import '../domain/services/plan_service.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileRepository(Get.find<ApiClient>()));
    Get.lazyPut(() => ProfileService(Get.find<ProfileRepository>()));
    Get.lazyPut(() => UpdateProfilePhotoUseCase(Get.find<ProfileService>()));
    Get.lazyPut(() => GetProfileUseCase(Get.find<ProfileService>()));
    Get.lazyPut(() => UpdateProfileInAppUseCase(Get.find<ProfileService>()));
    Get.lazyPut(() => GetFollowingUseCase(Get.find<ProfileService>()));
    Get.lazyPut(() => PlanRepository(Get.find<ApiClient>()));
    Get.lazyPut(() => PlanService(Get.find<PlanRepository>()));
    Get.lazyPut(() => GetPlansUseCase(Get.find<PlanService>()));
    Get.lazyPut(() => GetPlanByIdUseCase(Get.find<PlanService>()));
    Get.lazyPut(() => UpgradePlanUseCase(Get.find<PlanService>()));
    Get.lazyPut(() => VerifyUpgradeUseCase(Get.find<PlanService>()));
    Get.lazyPut(() =>
        ProfileController(
          updateProfilePhotoUseCase: Get.find<UpdateProfilePhotoUseCase>(),
          getProfileUseCase: Get.find<GetProfileUseCase>(),
          updateProfileInAppUseCase: Get.find<UpdateProfileInAppUseCase>(),
          getFollowingUseCase: Get.find<GetFollowingUseCase>(),
          getPlansUseCase: Get.find<GetPlansUseCase>(),
          getPlanByIdUseCase: Get.find<GetPlanByIdUseCase>(),
          upgradePlanUseCase: Get.find<UpgradePlanUseCase>(),
          verifyUpgradeUseCase: Get.find<VerifyUpgradeUseCase>(),
        ));
  }
}

