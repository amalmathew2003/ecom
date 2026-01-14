import 'package:ecom/features/user/cart/controller/card_controller.dart';
import 'package:ecom/service/checkout_service/checkout_mode.dart';
import 'package:get/get.dart';

class CheckoutController extends GetxController {
  final mode = CheckoutMode.cart.obs;
  //BUY NOW DATA
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

  double get payableAmount {
    if (mode.value == CheckoutMode.cart) {
      return Get.find<CartController>().totalAmount;
    } else {
      return buyNowAomunt ?? 0;
    }
  }
}
