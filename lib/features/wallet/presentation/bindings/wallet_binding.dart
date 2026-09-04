import 'package:get/get.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:astro_user/features/wallet/data/datasources/wallet_service.dart';
import 'package:astro_user/features/wallet/domain/usecases/get_wallet_usecase.dart';
import 'package:astro_user/features/wallet/domain/usecases/top_up_wallet_usecase.dart';
import 'package:astro_user/features/wallet/domain/usecases/verify_top_up_usecase.dart';
import 'package:astro_user/features/wallet/domain/usecases/get_transactions_usecase.dart';
import 'package:astro_user/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:astro_user/features/auth/data/datasources/auth_service_interface.dart';
import 'package:astro_user/core/services/payment/razorpay/razorpay_service.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletRepositoryInterface>(() => WalletRepository(apiClient: Get.find()));
    Get.lazyPut<WalletServiceInterface>(() => WalletService(repository: Get.find()));
    Get.lazyPut(() => GetWalletUseCase(service: Get.find()));
    Get.lazyPut(() => TopUpWalletUseCase(service: Get.find()));
    Get.lazyPut(() => VerifyTopUpUseCase(service: Get.find()));
    Get.lazyPut(() => GetTransactionsUseCase(service: Get.find()));
    Get.lazyPut(() => WalletController(
      getWalletUseCase: Get.find(),
      topUpWalletUseCase: Get.find(),
      verifyTopUpUseCase: Get.find(),
      getTransactionsUseCase: Get.find(),
      authService: Get.find<AuthServiceInterface>(),
      razorpayService: Get.find<RazorpayService>(),
    ));
  }
}
