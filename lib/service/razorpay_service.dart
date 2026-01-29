import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  Razorpay? _razorpay;

  void init({
    required Function(String paymentId) onSuccess,
    required Function(String error) onError,
  }) {
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse res) {
      if (res.paymentId != null) {
        onSuccess(res.paymentId!);
      }
    });
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse res) {
      onError(res.message ?? "Payment Failed");
    });
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse res) {
      onError("External wallet not supported");
    });
  }

  void openChackout({
    required double amount,
    required String email,
    required String phone,
  }) {
    final key = dotenv.env['RAZORPAY_TEST_KEY'];
    if (key == null) {
      Get.snackbar("Error", "RazorPay key is missing in .env");
      return;
    }

    if (_razorpay == null) {
      Get.snackbar("Error", "Payment service not initialized");
      return;
    }

    try {
      _razorpay!.open({
        "key": key,
        "amount": (amount * 100).toInt(),
        "name": "Neo Mart",
        "description": "Order Payment",
        "prefill": {"email": email, "contact": phone},
      });
    } catch (e) {
      Get.snackbar("Payment Error", "Could not open checkout: $e");
    }
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }
}
