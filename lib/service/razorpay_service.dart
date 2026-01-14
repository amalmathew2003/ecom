import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  late Razorpay _razorpay;
  void init({
    required Function(String paymentId) onSuccess,
    required Function(String error) onError,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse res) {
      onSuccess(res.paymentId!);
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse res) {
      onError(res.message ?? "payment Failed");
    });
  }

  void openChackout({
    required double amount,
    required String email,
    required String phone,
  }) {
    final key = dotenv.env['RAZORPAY_TEST_KEY'];
    if (key == null) {
      Get.snackbar("Error", "RazorPay key is Missisng");
      return;
    }
    _razorpay.open({
      "key": key,
      "amount": (amount * 100).toInt(),
      "name": "Ecom APP",
      "description": "Oder Payment",
      "profile": {"email": email, "contact": phone},
    });
  }

  void dispose() {
    _razorpay.clear();
  }
}
