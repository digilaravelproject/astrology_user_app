import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/network/api_client.dart';
import '../services/network/network_info.dart';
import 'package:dio/dio.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/services/auth_service.dart';
import '../../features/auth/domain/services/auth_service_interface.dart';
import '../../features/splash/controllers/splash_controller.dart';
import '../../features/splash/domain/repositories/splash_repository.dart';
import '../../features/splash/domain/services/splash_service.dart';
import '../../features/profile/bindings/profile_binding.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/astrologers/domain/repositories/astrologer_repository.dart';
import '../../features/astrologers/domain/services/astrologer_service.dart';
import '../../features/astrologers/domain/usecases/get_astrologers_usecase.dart';
import '../../features/astrologers/controllers/astrologer_controller.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/domain/services/wallet_service.dart';
import '../../features/wallet/domain/usecases/get_wallet_usecase.dart';
import '../../features/wallet/domain/usecases/top_up_wallet_usecase.dart';
import '../../features/wallet/domain/usecases/verify_top_up_usecase.dart';
import '../../features/wallet/controllers/wallet_controller.dart';
import '../../features/matrimony/domain/repositories/matrimony_repository.dart';
import '../../features/matrimony/domain/services/matrimony_service.dart';
import '../../features/matrimony/domain/usecases/save_matrimony_profile_usecase.dart';
import '../../features/matrimony/controllers/matrimony_controller.dart';
import '../services/payment/razorpay/razorpay_service.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Core services
    Get.put(Dio(), permanent: true);
    Get.put(ApiClient(), permanent: true);
    Get.put(Connectivity(), permanent: true);
    Get.put(NetworkInfo(Get.find<Connectivity>()), permanent: true);
    Get.put(RazorpayService(), permanent: true);

    // Splash
    Get.put(SplashRepository(Get.find<ApiClient>()), permanent: true);
    Get.put(SplashService(Get.find<SplashRepository>()), permanent: true);
    Get.put(SplashController(Get.find<SplashService>()), permanent: true);

    // Auth
    Get.put(AuthRepository(Get.find<ApiClient>()), permanent: true);
    final authService = AuthService(Get.find<AuthRepository>());
    Get.put<AuthService>(authService, permanent: true);
    Get.put<AuthServiceInterface>(authService, permanent: true);
    
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
    
    // Astrologers
    Get.lazyPut(() => AstrologerRepository(apiClient: Get.find()));
    Get.lazyPut(() => AstrologerService(repository: Get.find()));
    Get.lazyPut(() => GetAstrologersUseCase(service: Get.find()));
    Get.put(AstrologerController(getAstrologersUseCase: Get.find()));

    // Wallet
    Get.lazyPut<WalletRepositoryInterface>(() => WalletRepository(apiClient: Get.find()));
    Get.lazyPut<WalletServiceInterface>(() => WalletService(repository: Get.find()));
    Get.lazyPut(() => GetWalletUseCase(service: Get.find()));
    Get.lazyPut(() => TopUpWalletUseCase(service: Get.find()));
    Get.lazyPut(() => VerifyTopUpUseCase(service: Get.find()));
    Get.put(
      WalletController(
        getWalletUseCase: Get.find(),
        topUpWalletUseCase: Get.find(),
        verifyTopUpUseCase: Get.find(),
        authService: Get.find<AuthServiceInterface>(),
        razorpayService: Get.find<RazorpayService>(),
      ),
    );

    // Matrimony
    Get.lazyPut<MatrimonyRepositoryInterface>(() => MatrimonyRepository(apiClient: Get.find()));
    Get.lazyPut<MatrimonyServiceInterface>(() => MatrimonyService(repository: Get.find()));
    Get.lazyPut(() => SaveMatrimonyProfileUseCase(service: Get.find()));
    Get.put(MatrimonyController(saveMatrimonyProfileUseCase: Get.find()));

    // Home
    HomeBinding().dependencies();
  }
}
