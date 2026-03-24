import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/network/api_client.dart';
import '../services/network/network_info.dart';
import 'package:dio/dio.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/services/auth_service.dart';
import '../../features/splash/controllers/splash_controller.dart';
import '../../features/splash/domain/repositories/splash_repository.dart';
import '../../features/splash/domain/services/splash_service.dart';
import '../theme/theme_controller.dart';
import '../../features/profile/bindings/profile_binding.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Core services
    Get.put(Dio(), permanent: true);
    Get.put(ApiClient(), permanent: true);
    Get.put(Connectivity(), permanent: true);
    Get.put(NetworkInfo(Get.find<Connectivity>()), permanent: true);

    // Splash
    Get.put(SplashRepository(Get.find<ApiClient>()), permanent: true);
    Get.put(SplashService(Get.find<SplashRepository>()), permanent: true);
    Get.put(SplashController(Get.find<SplashService>()), permanent: true);

    // Auth
    Get.put(AuthRepository(Get.find<ApiClient>()), permanent: true);
    Get.put(AuthService(Get.find<AuthRepository>()), permanent: true);
    Get.put(LoginUseCase(Get.find<AuthService>()), permanent: true);
    Get.put(RegisterUseCase(Get.find<AuthService>()), permanent: true);
    Get.put(VerifyOtpUseCase(Get.find<AuthService>()), permanent: true);
    Get.put(LogoutUseCase(Get.find<AuthService>()), permanent: true);
    Get.put(CheckLoginStatusUseCase(Get.find<AuthService>()), permanent: true);
    Get.put(GetUserInfoUseCase(Get.find<AuthService>()), permanent: true);
    Get.put(SendOtpUseCase(Get.find<AuthService>()), permanent: true);
    Get.put(ResendOtpUseCase(Get.find<AuthService>()), permanent: true);
    Get.put(UpdateProfileUseCase(Get.find<AuthService>()), permanent: true);
    Get.put(
      AuthController(
        loginUseCase: Get.find<LoginUseCase>(),
        registerUseCase: Get.find<RegisterUseCase>(),
        verifyOtpUseCase: Get.find<VerifyOtpUseCase>(),
        logoutUseCase: Get.find<LogoutUseCase>(),
        checkLoginStatusUseCase: Get.find<CheckLoginStatusUseCase>(),
        getUserInfoUseCase: Get.find<GetUserInfoUseCase>(),
        sendOtpUseCase: Get.find<SendOtpUseCase>(),
        resendOtpUseCase: Get.find<ResendOtpUseCase>(),
        updateProfileUseCase: Get.find<UpdateProfileUseCase>(),
      ),
      permanent: true,
    );

    // Profile
    ProfileBinding().dependencies();
  }
}
