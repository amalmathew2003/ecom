import 'package:ecom/features/user/cart/controller/card_controller.dart';
import 'package:ecom/features/user/profile/controller/profile_controller.dart';
import 'package:ecom/features/user/checkout/controller/checkout_controller.dart';
import 'package:ecom/features/user/checkout/controller/checkout_mode.dart';
import 'package:ecom/features/user/checkout/ui/payment_method_selector.dart';
import 'package:ecom/service/razorpay_service.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final checkoutCrl = Get.find<CheckoutController>();
  final cartCrl = Get.find<CartController>();
  final profileCrl = Get.find<ProfileController>();
  final razorpayService = RazorpayService();

  @override
  void initState() {
    super.initState();

    /// 🔒 SAFETY: ensure cart amount is loaded
    if (checkoutCrl.mode.value == CheckoutMode.cart) {
      cartCrl.fetchCart();
    }
  }

  @override
  void dispose() {
    razorpayService.dispose();
    super.dispose();
  }

  /// ================= PAYMENT =================
  Future<void> payment() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      Get.snackbar("Error", "User not logged in");
      return;
    }

    /// 🔴 FINAL GUARD — this fixes your issue
    final amount = checkoutCrl.payableAmount;
    if (amount <= 0) {
      Get.snackbar(
        "Checkout Error",
        "Amount not ready. Please retry.",
        backgroundColor: ColorConst.card,
        colorText: ColorConst.textLight,
      );
      return;
    }

    /// ================= COD =================
    if (checkoutCrl.isCod) {
      await _placeCodOrder();
      return;
    }

    /// ================= ONLINE =================
    _startOnlinePayment();
  }

  /// ================= ONLINE =================
  void _startOnlinePayment() {
    final user = Supabase.instance.client.auth.currentUser!;

    razorpayService.init(
      onSuccess: (paymentId) async {
        if (checkoutCrl.mode.value == CheckoutMode.cart) {
          await _placeCartOrder(paymentId);
        } else {
          await _placeBuyNowOrder(paymentId);
        }

        Get.offAllNamed('/orders');
        Get.snackbar("Success", "Order placed successfully");
      },
      onError: (error) {
        Get.snackbar("Payment Failed", error);
      },
    );

    razorpayService.openChackout(
      amount: checkoutCrl.payableAmount,
      email: user.email ?? '',
      phone: profileCrl.profile.value?.phone ?? '',
    );
  }

  /// ================= COD =================
  Future<void> _placeCodOrder() async {
    await Supabase.instance.client.from('orders').insert({
      'user_id': userId,
      'amount': checkoutCrl.payableAmount,
      'payment_method': 'COD',
      'payment_status': 'PENDING',
      'order_type':
          checkoutCrl.mode.value == CheckoutMode.cart ? 'CART' : 'BUY_NOW',
    });

    await Supabase.instance.client
        .from('cart')
        .delete()
        .eq('user_id', userId);

    cartCrl.cartItems.clear();

    Get.offAllNamed('/orders');
    Get.snackbar("Order Placed", "Cash on Delivery selected");
  }

  String get userId =>
      Supabase.instance.client.auth.currentUser!.id;

  /// ================= DB HELPERS =================
  Future<void> _placeCartOrder(String paymentId) async {
    await Supabase.instance.client.from('orders').insert({
      'user_id': userId,
      'amount': cartCrl.totalAmount,
      'payment_id': paymentId,
      'payment_method': 'RAZORPAY',
      'payment_status': 'SUCCESS',
      'order_type': 'CART',
    });

    await Supabase.instance.client
        .from('cart')
        .delete()
        .eq('user_id', userId);

    cartCrl.cartItems.clear();
  }

  Future<void> _placeBuyNowOrder(String paymentId) async {
    await Supabase.instance.client.from('orders').insert({
      'user_id': userId,
      'product_id': checkoutCrl.productId,
      'amount': checkoutCrl.buyNowAomunt,
      'payment_id': paymentId,
      'payment_method': 'RAZORPAY',
      'payment_status': 'SUCCESS',
      'order_type': 'BUY_NOW',
    });
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: ColorConst.bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Checkout",
          style: TextStyle(color: ColorConst.textLight),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _summaryCard(),
            const SizedBox(height: 20),

            /// 🔹 NEW PAYMENT UI
            const PaymentMethodSelector(),

            const Spacer(),
            _payButton(),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ColorConst.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Total",
                style: TextStyle(color: ColorConst.textMuted)),
            Text(
              "₹${checkoutCrl.payableAmount.toStringAsFixed(0)}",
              style: const TextStyle(
                color: ColorConst.accent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _payButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: payment,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConst.accent,
          foregroundColor: ColorConst.textDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: const Text(
          "Place Order",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
