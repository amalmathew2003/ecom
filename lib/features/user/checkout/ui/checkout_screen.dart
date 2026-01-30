import 'package:ecom/features/user/cart/controller/card_controller.dart';
import 'package:ecom/features/user/orders/controller/order_controller.dart';
import 'package:ecom/features/user/profile/controller/profile_controller.dart';
import 'package:ecom/features/user/checkout/controller/checkout_controller.dart';
import 'package:ecom/features/user/checkout/controller/checkout_mode.dart';
import 'package:ecom/features/user/checkout/ui/payment_method_selector.dart';
import 'package:ecom/service/razorpay_service.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecom/features/user/nav/controller/nav_controller.dart';

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
  final isLoading = false.obs;

  @override
  void initState() {
    super.initState();

    /// 🔒 SAFETY: ensure cart amount is loaded
    if (checkoutCrl.mode.value == CheckoutMode.cart) {
      cartCrl.fetchCart();
    }

    /// 💳 Initialize Razorpay once
    razorpayService.init(
      onSuccess: _onPaymentSuccess,
      onError: _onPaymentError,
    );
  }

  void _onPaymentSuccess(String paymentId) async {
    try {
      isLoading.value = true;
      if (checkoutCrl.mode.value == CheckoutMode.cart) {
        await _placeCartOrder(paymentId);
      } else {
        await _placeBuyNowOrder(paymentId);
      }

      // 🔄 Sync orders before navigating back
      await Get.find<OrderController>().fetchOrders();

      Get.offAllNamed('/user-nav'); // Go back to root
      Get.snackbar(
        "Success",
        "Order placed successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.log("Transaction Error: $e");
      Get.defaultDialog(
        title: "Order Error",
        middleText:
            "Payment was successful but we couldn't record your order.\n\nError: $e\n\nPlease contact support with Payment ID: $paymentId",
        textConfirm: "OK",
        onConfirm: () => Get.back(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _onPaymentError(String error) {
    Get.snackbar(
      "Payment Failed",
      error,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
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

    final amount = checkoutCrl.payableAmount;
    if (amount <= 0) {
      Get.snackbar("Error", "Invalid amount. Please try again.");
      return;
    }

    // Verify Address and Phone
    final profile = profileCrl.profile.value;
    if (profile == null ||
        profile.address.trim().isEmpty ||
        profile.phone.trim().isEmpty) {
      Get.snackbar(
        "Missing Information",
        "Please update your shipping address and phone number in your profile before placing an order.",
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () {
            Get.offNamed('/user-nav');
            Future.delayed(const Duration(milliseconds: 300), () {
              if (Get.isRegistered<UserNavController>()) {
                Get.find<UserNavController>().changeTab(2);
              }
            });
          },
          child: const Text(
            "Update Profile",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
      return;
    }

    if (checkoutCrl.isCod) {
      await _placeCodOrder();
      return;
    }

    /// ONLINE
    final userEmail = user.email ?? '';
    final userPhone = profileCrl.profile.value?.phone ?? '';

    razorpayService.openChackout(
      amount: amount,
      email: userEmail,
      phone: userPhone,
    );
  }

  /// ================= COD =================
  Future<void> _placeCodOrder() async {
    try {
      isLoading.value = true;
      final uid = Supabase.instance.client.auth.currentUser!.id;

      final profile = profileCrl.profile.value;

      final orderResponse = await Supabase.instance.client
          .from('orders')
          .insert({
            'user_id': uid,
            'amount': checkoutCrl.payableAmount,
            'payment_method': 'COD',
            'payment_status': 'PENDING',
            'order_type': checkoutCrl.mode.value == CheckoutMode.cart
                ? 'CART'
                : 'BUY_NOW',
            'shipping_address': profile?.address ?? '',
            'customer_phone': profile?.phone ?? '',
            if (checkoutCrl.mode.value == CheckoutMode.buyNow)
              'product_id': checkoutCrl.productId,
          })
          .select('id')
          .single();

      final String orderId = orderResponse['id'].toString();

      // Save individual items to order_items
      if (checkoutCrl.mode.value == CheckoutMode.cart) {
        final items = cartCrl.cartItems
            .map(
              (item) => {
                'order_id': orderId,
                'product_id': item.product.id,
                'quantity': item.quantity,
                'price': item.product.price,
              },
            )
            .toList();
        await Supabase.instance.client.from('order_items').insert(items);
      } else {
        // Buy Now logic: we need to find the product price
        // (Assuming we have access to the product or just use buyNowAmount)
        await Supabase.instance.client.from('order_items').insert({
          'order_id': orderId,
          'product_id': checkoutCrl.productId,
          'quantity': 1,
          'price': checkoutCrl.buyNowAmount ?? 0,
        });
      }

      if (checkoutCrl.mode.value == CheckoutMode.cart) {
        await Supabase.instance.client.from('cart').delete().eq('user_id', uid);
        cartCrl.cartItems.clear();
      } else {
        await Supabase.instance.client
            .from('cart')
            .delete()
            .eq('user_id', uid)
            .eq('product_id', checkoutCrl.productId!);
        cartCrl.fetchCart();
      }

      // 🔄 Sync orders before navigating back
      await Get.find<OrderController>().fetchOrders();

      Get.offAllNamed('/user-nav');
      Get.snackbar("Order Confirmed", "Your COD order has been placed.");
    } catch (e) {
      Get.snackbar("Error", "Failed to place order: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= DB HELPERS =================
  Future<void> _placeCartOrder(String paymentId) async {
    final uid = Supabase.instance.client.auth.currentUser!.id;

    final profile = profileCrl.profile.value;

    final orderResponse = await Supabase.instance.client
        .from('orders')
        .insert({
          'user_id': uid,
          'amount': cartCrl.totalAmount,
          'payment_id': paymentId,
          'payment_method': 'RAZORPAY',
          'payment_status': 'SUCCESS',
          'order_type': 'CART',
          'shipping_address': profile?.address ?? '',
          'customer_phone': profile?.phone ?? '',
        })
        .select('id')
        .single();

    final String orderId = orderResponse['id'].toString();

    // Save individual items
    final items = cartCrl.cartItems
        .map(
          (item) => {
            'order_id': orderId,
            'product_id': item.product.id,
            'quantity': item.quantity,
            'price': item.product.price,
          },
        )
        .toList();
    await Supabase.instance.client.from('order_items').insert(items);

    await Supabase.instance.client.from('cart').delete().eq('user_id', uid);
    cartCrl.cartItems.clear();
  }

  Future<void> _placeBuyNowOrder(String paymentId) async {
    final uid = Supabase.instance.client.auth.currentUser!.id;

    final profile = profileCrl.profile.value;

    final orderResponse = await Supabase.instance.client
        .from('orders')
        .insert({
          'user_id': uid,
          'product_id': checkoutCrl.productId,
          'amount': checkoutCrl.buyNowAmount,
          'payment_id': paymentId,
          'payment_method': 'RAZORPAY',
          'payment_status': 'SUCCESS',
          'order_type': 'BUY_NOW',
          'shipping_address': profile?.address ?? '',
          'customer_phone': profile?.phone ?? '',
        })
        .select('id')
        .single();

    final String orderId = orderResponse['id'].toString();

    await Supabase.instance.client.from('order_items').insert({
      'order_id': orderId,
      'product_id': checkoutCrl.productId,
      'quantity': 1,
      'price': checkoutCrl.buyNowAmount ?? 0,
    });

    await Supabase.instance.client
        .from('cart')
        .delete()
        .eq('user_id', uid)
        .eq('product_id', checkoutCrl.productId!);
    cartCrl.fetchCart();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: ColorConst.bg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Checkout",
              style: TextStyle(
                color: ColorConst.textLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ColorConst.textLight,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _summaryCard(),
                const SizedBox(height: 16),
                _shippingSection(),
                const SizedBox(height: 24),
                const PaymentMethodSelector(),
                const Spacer(),
                _payButton(),
              ],
            ),
          ),
        ),
        Obx(() {
          if (isLoading.value) {
            return Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: ColorConst.primary),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _summaryCard() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ColorConst.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: ColorConst.surface.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Total Payable",
              style: TextStyle(
                color: ColorConst.textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "₹${checkoutCrl.payableAmount.toStringAsFixed(0)}",
              style: const TextStyle(
                color: ColorConst.primary,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _shippingSection() {
    return Obx(() {
      final profile = profileCrl.profile.value;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ColorConst.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: ColorConst.surface.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Shipping To",
                  style: TextStyle(
                    color: ColorConst.textLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.offNamed('/user-nav');
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (Get.isRegistered<UserNavController>()) {
                        Get.find<UserNavController>().changeTab(2);
                      }
                    });
                  },
                  child: const Text(
                    "Edit",
                    style: TextStyle(
                      color: ColorConst.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: ColorConst.primary,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    profile?.address.isNotEmpty == true
                        ? profile!.address
                        : "No address set. Please update in profile.",
                    style: TextStyle(
                      color: profile?.address.isNotEmpty == true
                          ? ColorConst.textLight
                          : Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.phone_rounded,
                  color: ColorConst.primary,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  profile?.phone.isNotEmpty == true
                      ? profile!.phone
                      : "No phone number",
                  style: const TextStyle(
                    color: ColorConst.textLight,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _payButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          gradient: ColorConst.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ColorConst.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading.value ? null : payment,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            "Place Order",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
