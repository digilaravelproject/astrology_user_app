import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'razorpay_config.dart';
import '../../../utils/custom_snackbar.dart';

class RazorpayService {
  late Razorpay _razorpay;
  
  // Callbacks
  Function(PaymentSuccessResponse)? _onSuccess;
  Function(PaymentFailureResponse)? _onFailure;
  Function(ExternalWalletResponse)? _onExternalWallet;

  void init({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) {
    _razorpay = Razorpay();
    _onSuccess = onSuccess;
    _onFailure = onFailure;
    _onExternalWallet = onExternalWallet;

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_onSuccess != null) _onSuccess!(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (_onFailure != null) _onFailure!(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (_onExternalWallet != null) _onExternalWallet!(response);
  }

  void openCheckout({
    required double amount,
    required String orderId,
    required String name,
    required String description,
    required String email,
    required String contact,
  }) {
    // Strip redundant prefix if present (Razorpay SDK expects 'order_...')
    String finalOrderId = orderId;
    if (orderId.startsWith('razorpay_order_')) {
      finalOrderId = orderId.replaceFirst('razorpay_order_', 'order_');
    } else if (orderId.startsWith('razorpay_')) {
      finalOrderId = orderId.replaceFirst('razorpay_', '');
    }

    print('[PCB_APP] [DEBUG] | Generating Razorpay options...');
    final options = RazorpayConfig.getDefaultOptions(
      key: RazorpayConfig.razorpayKey,
      amount: amount,
      orderId: finalOrderId,
      name: name,
      description: description,
      email: email,
      contact: contact,
    );

    print('[PCB_APP] [DEBUG] | Razorpay Options: $options');

    try {
      print('[PCB_APP] [DEBUG] | Calling _razorpay.open(options) with delay...');
      // Small delay ensures the UI is ready and doesn't block the main thread transition
      Future.delayed(const Duration(milliseconds: 500), () {
        _razorpay.open(options);
      });
    } catch (e) {
      print('[PCB_APP] [DEBUG] | Error in _razorpay.open: $e');
      CustomSnackbar.showError('Could not open Razorpay checkout: $e');
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
