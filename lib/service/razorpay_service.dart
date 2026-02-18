import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService extends GetxService {
  late Razorpay _razorpay;

  Function(String paymentId)? _onSuccess;
  Function(String error)? _onFailure;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void setupCallbacks({
    required Function(String paymentId) onSuccess,
    required Function(String error) onError,
  }) {
    _onSuccess = onSuccess;
    _onFailure = onError;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (response.paymentId != null) {
      _onSuccess?.call(response.paymentId!);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _onFailure?.call(response.message ?? "Payment Failed");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _onFailure?.call("External wallet not supported");
  }

  void openCheckout({
    required double amount,
    required String email,
    required String phone,
  }) {
    final key = dotenv.env['RAZORPAY_TEST_KEY'];
    if (key == null || key.isEmpty) {
      Get.snackbar("SYSTEM ERROR", "RAZORPAY KEY IS MISSING IN .ENV");
      return;
    }

    try {
      var options = {
        'key': key,
        'amount': (amount * 100).round(), // Amount in paise
        'name': 'NEO MART',
        'description': 'ORDER PAYMENT',
        'prefill': {'contact': phone, 'email': email},
        'external': {
          'wallets': ['paytm'],
        },
        'theme': {'color': '#00F3FF'}, // Matching Neo accent color
      };

      _razorpay.open(options);
    } catch (e) {
      Get.log("Razorpay Open Error: $e");
      Get.snackbar("PAYMENT ERROR", "COULD NOT OPEN CHECKOUT: $e");
    }
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}
