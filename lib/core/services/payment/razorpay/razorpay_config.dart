class RazorpayConfig {
  static const String razorpayKey = 'rzp_test_S9yXFuXcf0S6Ll'; // Replace with actual Razorpay key
  
  static const String currency = 'INR';
  static const int timeout = 300; // in seconds
  
  static Map<String, dynamic> getDefaultOptions({
    required String key,
    required double amount,
    required String orderId,
    required String name,
    required String description,
    required String email,
    required String contact,
  }) {
    return {
      'key': key,
      'amount': (amount * 100).toInt(),
      'name': name,
      'order_id': orderId,
      'description': description,
      'timeout': timeout,
      'currency': currency,
      'prefill': {
        'contact': contact,
        'email': email,
      }
    };
  }
}
