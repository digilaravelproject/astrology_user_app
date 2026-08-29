import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../domain/repositories/wallet_repository.dart';
import '../domain/services/wallet_service.dart';
import '../domain/usecases/get_wallet_usecase.dart';
import '../domain/usecases/top_up_wallet_usecase.dart';
import '../domain/usecases/verify_top_up_usecase.dart';
import '../domain/usecases/get_transactions_usecase.dart';
import '../controllers/wallet_controller.dart';
import '../../auth/domain/services/auth_service_interface.dart';
import '../../../core/services/payment/razorpay/razorpay_service.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletRepositoryInterface>(
      () => WalletRepository(apiClient: Get.find()),
    );
    Get.lazyPut<WalletServiceInterface>(
      () => WalletService(repository: Get.find()),
    );
    Get.lazyPut(() => GetWalletUseCase(service: Get.find()));
    Get.lazyPut(() => TopUpWalletUseCase(service: Get.find()));
    Get.lazyPut(() => VerifyTopUpUseCase(service: Get.find()));
    Get.lazyPut(() => GetTransactionsUseCase(service: Get.find()));
    Get.lazyPut(
      () => WalletController(
        getWalletUseCase: Get.find(),
        topUpWalletUseCase: Get.find(),
        verifyTopUpUseCase: Get.find(),
        getTransactionsUseCase: Get.find(),
        authService: Get.find<AuthServiceInterface>(),
        razorpayService: Get.find<RazorpayService>(),
      ),
    );
  }
}
