import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/services/payment/razorpay/razorpay_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/domain/services/auth_service_interface.dart';
import '../domain/usecases/get_wallet_usecase.dart';
import '../domain/usecases/top_up_wallet_usecase.dart';
import '../domain/usecases/verify_top_up_usecase.dart';
import '../domain/models/wallet_model.dart';
import '../domain/models/wallet_top_up_response_model.dart';

import '../../../core/utils/custom_snackbar.dart';

class WalletController extends GetxController {
  final GetWalletUseCase getWalletUseCase;
  final TopUpWalletUseCase topUpWalletUseCase;
  final VerifyTopUpUseCase verifyTopUpUseCase;
  final AuthServiceInterface authService;
  final RazorpayService razorpayService;

  WalletController({
    required this.getWalletUseCase,
    required this.topUpWalletUseCase,
    required this.verifyTopUpUseCase,
    required this.authService,
    required this.razorpayService,
  });

  final wallet = Rxn<WalletModel>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWallet();
    razorpayService.init(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
  }

  @override
  void onClose() {
    razorpayService.dispose();
    super.onClose();
  }

  Future<void> fetchWallet() async {
    isLoading.value = true;
    try {
      final result = await getWalletUseCase.execute();
      if (result != null) {
        wallet.value = result;
      }
    } catch (e) {
      print('Error fetching wallet: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startTopUp(double amount) async {
    print('[PCB_APP] [DEBUG] | startTopUp called with amount: $amount');
    isLoading.value = true;
    try {
      final result = await topUpWalletUseCase.execute(amount);
      print("[PCB_APP] [DEBUG] | startTopUp called with result: $result");
      if (result != null) {
        print('[PCB_APP] [DEBUG] | Top-up order created successfully. Provider Order ID: ${result.data.transaction.providerOrderId}');
        final user = await authService.getUserInfo();
        print('[PCB_APP] [DEBUG] | Opening Razorpay Checkout...');
        razorpayService.openCheckout(
          amount: amount,
          orderId: result.data.transaction.providerOrderId,
          name: AppConstants.appName,
          description: 'Wallet Top-up',
          email: 'user@example.com', // UserModel doesn't have email, using placeholder or name
          contact: user?.mobile ?? '',
        );
      } else {
        print('[PCB_APP] [DEBUG] | Failed to create top-up order: result is null');
        CustomSnackbar.showError('Failed to create top-up order');
      }
    } catch (e) {
      print('[PCB_APP] [DEBUG] | Error in startTopUp: $e');
      CustomSnackbar.showError('An error occurred while starting top-up');
    } finally {
      isLoading.value = false;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    isLoading.value = true;
    try {
      final result = await verifyTopUpUseCase.execute(
        providerOrderId: response.orderId ?? '',
        providerPaymentId: response.paymentId ?? '',
        signature: response.signature ?? '',
      );

      if (result != null && result.status == 'success') {
        CustomSnackbar.showSuccess(result.message);
        fetchWallet();
      } else {
        CustomSnackbar.showError(result?.message ?? 'Payment verification failed');
      }
    } catch (e) {
      print('Error verifying payment: $e');
      CustomSnackbar.showError('An error occurred during payment verification');
    } finally {
      isLoading.value = false;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    CustomSnackbar.showError(response.message ?? 'Unknown error', title: 'Payment Failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    CustomSnackbar.showInfo(response.walletName ?? '', title: 'External Wallet');
  }

  String get balance => wallet.value?.balance ?? '0.00';
}
