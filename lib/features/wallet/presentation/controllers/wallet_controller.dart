import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:astro_user/core/services/payment/razorpay/razorpay_service.dart';
import 'package:astro_user/core/constants/app_constants.dart';
import 'package:astro_user/features/auth/data/datasources/auth_service_interface.dart';
import 'package:astro_user/features/wallet/domain/usecases/get_transactions_usecase.dart';
import 'package:astro_user/features/wallet/domain/usecases/get_wallet_usecase.dart';
import 'package:astro_user/features/wallet/domain/usecases/top_up_wallet_usecase.dart';
import 'package:astro_user/features/wallet/domain/usecases/verify_top_up_usecase.dart';
import 'package:astro_user/features/wallet/data/models/wallet_model.dart';
import 'package:astro_user/features/wallet/data/models/wallet_top_up_response_model.dart';

import 'package:astro_user/core/utils/custom_snackbar.dart';
import 'package:astro_user/core/widgets/payment_success_dialog.dart';
import 'package:astro_user/routes/route_helper.dart';

class WalletController extends GetxController {
  final GetWalletUseCase getWalletUseCase;
  final TopUpWalletUseCase topUpWalletUseCase;
  final VerifyTopUpUseCase verifyTopUpUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;
  final AuthServiceInterface authService;
  final RazorpayService razorpayService;

  WalletController({
    required this.getWalletUseCase,
    required this.topUpWalletUseCase,
    required this.verifyTopUpUseCase,
    required this.getTransactionsUseCase,
    required this.authService,
    required this.razorpayService,
  });

  final wallet = Rxn<WalletModel>();
  final transactions = <TransactionModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWallet();
    fetchTransactions();
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
      print('[PCB_APP] [DEBUG] | fetchWallet result: ${result?.balance}');
      if (result != null) {
        wallet.value = result;
        print('[PCB_APP] [DEBUG] | wallet.value updated: ${wallet.value?.balance}');
      }
    } catch (e) {
      print('[PCB_APP] [DEBUG] | Error fetching wallet in Controller: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTransactions() async {
    try {
      final result = await getTransactionsUseCase.execute();
      if (result != null) {
        transactions.assignAll(result.data.transactions);
      }
    } catch (e) {
      print('Error fetching transactions: $e');
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
        
        // Refresh to show the pending transaction immediately
        fetchWallet();
        fetchTransactions();

        final user = await authService.getUserInfo();
        final rzpKey = result.data.razorpayKey;
        if (rzpKey == null || rzpKey.isEmpty) {
          print('[PCB_APP] [DEBUG] | Failed to start checkout: Razorpay Key missing from backend');
          CustomSnackbar.showError('Payment configuration missing from server');
          return;
        }

        print('[PCB_APP] [DEBUG] | Opening Razorpay Checkout...');
        razorpayService.openCheckout(
          amount: amount,
          orderId: result.data.transaction.providerOrderId,
          name: AppConstants.appName,
          description: 'Wallet Top-up',
          email: 'user@example.com', // UserModel doesn't have email, using placeholder or name
          contact: user?.mobile ?? '',
          razorpayKey: rzpKey,
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
        // Refresh data immediately
        fetchWallet();
        fetchTransactions();

        // Navigate to success screen instead of dialog
        Get.offNamed(
          RouteHelper.getPaymentSuccessRoute(),
          arguments: {
            'amount': result.data.transaction.amount,
            'orderId': response.orderId,
          },
        );
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
    CustomSnackbar.showError(response.message ?? 'Unknown error', title: 'Payment Failed'.tr);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    CustomSnackbar.showInfo(response.walletName ?? '', title: 'External Wallet'.tr);
  }

  String get balance => wallet.value?.balance ?? '0.00';
}
