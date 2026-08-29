import 'package:get/get.dart';
import 'package:astro_user/features/call/presentation/controllers/call_controller.dart';
import 'package:astro_user/features/live/presentation/bindings/live_binding.dart';
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
import '../services/payment/razorpay/razorpay_service.dart';
import '../services/network/websocket_service.dart';
import '../services/network/presence_controller.dart';
import '../../features/chat/data/datasources/chat_remote_data_source.dart';
import '../../features/chat/data/datasources/chat_local_data_source.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/i_chat_repository.dart';
import '../../features/chat/domain/usecases/sync_message_status_usecase.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Core services
    Get.put(Dio(), permanent: true);
    Get.put(ApiClient(), permanent: true);
    Get.put(Connectivity(), permanent: true);
    Get.put(NetworkInfo(Get.find<Connectivity>()), permanent: true);
    Get.put(RazorpayService(), permanent: true);
    
    // Presence & WebSockets
    Get.put(PresenceController(), permanent: true);
    final wsService = Get.put(WebSocketService(), permanent: true);
    wsService.init().then((_) {
      // Connect will automatically attempt connecting if token exists
      wsService.connect();
    });

    // Chat global dependencies (needed by WebSocketService)
    Get.put<IChatRemoteDataSource>(ChatRemoteDataSourceImpl(apiClient: Get.find<ApiClient>()), permanent: true);
    Get.put<IChatLocalDataSource>(ChatLocalDataSourceImpl(), permanent: true);
    Get.put<IChatRepository>(ChatRepositoryImpl(remoteDataSource: Get.find<IChatRemoteDataSource>(), localDataSource: Get.find<IChatLocalDataSource>()), permanent: true);
    Get.put(SyncMessageStatusUseCase(Get.find<IChatRepository>()), permanent: true);

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
    Get.put(DeleteAccountUseCase(Get.find<AuthService>()), permanent: true);
    
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
        deleteAccountUseCase: Get.find<DeleteAccountUseCase>(),
      ),
      permanent: true,
    );

    // Call dependencies
    Get.put(CallController(), permanent: true);

    // Live dependencies
    LiveBinding().dependencies();
  }
}
