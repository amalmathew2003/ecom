import 'package:ecom/features/user/cart/controller/card_controller.dart';
import 'package:ecom/features/user/checkout/controller/checkout_mode.dart';
import 'package:get/get.dart';

enum PaymentMethod { cod, online }

class CheckoutController extends GetxController {
  final mode = CheckoutMode.cart.obs;

  /// payment method state
  final paymentMethod = PaymentMethod.online.obs;

  // BUY NOW DATA
  String? productId;
  double? buyNowAomunt;

  void setCartChekout() {
    mode.value = CheckoutMode.cart;
    productId = null;
    buyNowAomunt = null;
  }

  void setBuyNow({required String productId, required double amount}) {
    mode.value = CheckoutMode.buyNow;
    this.productId = productId;
    buyNowAomunt = amount;
  }

  void selectPaymentMethod(PaymentMethod method) {
    paymentMethod.value = method;
  }

  bool get isCod => paymentMethod.value == PaymentMethod.cod;
  bool get isOnline => paymentMethod.value == PaymentMethod.online;

  double get payableAmount {
    if (mode.value == CheckoutMode.cart) {
      return Get.find<CartController>().totalAmount;
    } else {
      return buyNowAomunt ?? 0;
    }
  }
}
