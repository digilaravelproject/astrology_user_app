import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../controllers/profile_controller.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/services/profile_service.dart';
import '../domain/usecases/update_profile_photo_usecase.dart';
import '../domain/usecases/get_profile_usecase.dart';
import '../domain/usecases/update_profile_in_app_usecase.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ProfileRepository(Get.find<ApiClient>()), permanent: true);
    Get.put(ProfileService(Get.find<ProfileRepository>()), permanent: true);
    Get.put(UpdateProfilePhotoUseCase(Get.find<ProfileService>()), permanent: true);
    Get.put(GetProfileUseCase(Get.find<ProfileService>()), permanent: true);
    Get.put(UpdateProfileInAppUseCase(Get.find<ProfileService>()), permanent: true);
    Get.put(
      ProfileController(
        updateProfilePhotoUseCase: Get.find<UpdateProfilePhotoUseCase>(),
        getProfileUseCase: Get.find<GetProfileUseCase>(),
        updateProfileInAppUseCase: Get.find<UpdateProfileInAppUseCase>(),
      ),
      permanent: true,
    );
  }
}
