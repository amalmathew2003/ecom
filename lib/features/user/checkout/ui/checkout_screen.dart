import 'package:ecom/features/user/cart/controller/card_controller.dart';
import 'package:ecom/features/user/orders/controller/order_controller.dart';
import 'package:ecom/features/user/profile/controller/profile_controller.dart';
import 'package:ecom/features/user/checkout/controller/checkout_controller.dart';
import 'package:ecom/features/user/checkout/controller/checkout_mode.dart';
import 'package:ecom/features/user/checkout/ui/payment_method_selector.dart';
import 'package:ecom/features/user/checkout/ui/order_success_screen.dart';
import 'package:ecom/service/razorpay_service.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:ecom/core/utils/responsive_layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
  final razorpayService = Get.find<RazorpayService>();
  final isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    if (checkoutCrl.mode.value == CheckoutMode.cart) {
      cartCrl.fetchCart();
    }
    razorpayService.setupCallbacks(
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
      await Get.find<OrderController>().fetchOrders();
      Get.offAll(() => const OrderSuccessScreen());
    } catch (e) {
      Get.log("Transaction Error: $e");
      Get.defaultDialog(
        backgroundColor: NeoColors.surface,
        title: "ORDER ERROR",
        titleStyle: GoogleFonts.oswald(color: NeoColors.error),
        middleText:
            "Payment successful but recording failed.\n\n$e\n\nPayment ID: $paymentId",
        middleTextStyle: GoogleFonts.montserrat(color: NeoColors.textMedium),
        textConfirm: "CONTACT SUPPORT",
        onConfirm: () => Get.back(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _onPaymentError(String error) {
    isLoading.value = false;
    Get.snackbar(
      "PAYMENT FAILED",
      error.toUpperCase(),
      backgroundColor: NeoColors.error.withOpacity(0.1),
      colorText: NeoColors.error,
    );
  }

  Future<void> payment() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      Get.snackbar("ERROR", "PLEASE LOG IN TO CONTINUE");
      return;
    }

    final amount = checkoutCrl.payableAmount;
    if (amount <= 0) {
      Get.snackbar("ERROR", "INVALID TRANSACTION AMOUNT");
      return;
    }

    final profile = profileCrl.profile.value;
    if (profile == null ||
        profile.address.trim().isEmpty ||
        profile.phone.trim().isEmpty) {
      Get.snackbar(
        "INFO MISSING",
        "UPDATE SHIPPING ADDRESS & PHONE IN PROFILE",
        backgroundColor: Colors.orangeAccent.withOpacity(0.1),
        colorText: Colors.orangeAccent,
        mainButton: TextButton(
          onPressed: () {
            Get.offNamed('/user-nav');
            Future.delayed(const Duration(milliseconds: 300), () {
              if (Get.isRegistered<UserNavController>()) {
                Get.find<UserNavController>().changeTab(2);
              }
            });
          },
          child: Text(
            "UPDATE",
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      return;
    }

    if (checkoutCrl.isCod) {
      await _placeCodOrder();
      return;
    }

    final userEmail = user.email ?? '';
    final userPhone = profile.phone;

    try {
      razorpayService.openCheckout(
        amount: amount,
        email: userEmail,
        phone: userPhone,
      );
    } catch (e) {
      Get.snackbar("SYSTEM ERROR", "FAILED TO INITIALIZE PAYMENT: $e");
    }
  }

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
            'status': 'PENDING',
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
        await Supabase.instance.client.from('cart').delete().eq('user_id', uid);
        cartCrl.cartItems.clear();
      } else {
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

      await Get.find<OrderController>().fetchOrders();
      Get.offAll(() => const OrderSuccessScreen());
    } catch (e) {
      Get.snackbar("ERROR", "DATABASE ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

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
          'status': 'SUCCESS',
          'order_type': 'CART',
          'shipping_address': profile?.address ?? '',
          'customer_phone': profile?.phone ?? '',
        })
        .select('id')
        .single();

    final String orderId = orderResponse['id'].toString();

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
          'status': 'SUCCESS',
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
    return Scaffold(
      backgroundColor: NeoColors.background,
      body: ResponsiveLayout(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 120),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (ResponsiveLayout.isMobile(context)) {
                          return Column(
                            children: [
                              _summaryCard(),
                              const SizedBox(height: 24),
                              _shippingSection(),
                              const SizedBox(height: 32),
                              const PaymentMethodSelector(),
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  _summaryCard(),
                                  const SizedBox(height: 24),
                                  _shippingSection(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 40),
                            const Expanded(
                              flex: 1,
                              child: PaymentMethodSelector(),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Obx(() => _payButton()),
            ),
            Obx(() {
              if (isLoading.value) {
                return Container(
                  color: Colors.black.withOpacity(0.85),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: NeoColors.accent,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "PROCESSING TRANSACTION...",
                          style: GoogleFonts.oswald(
                            color: NeoColors.accent,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: NeoColors.textHigh,
            ),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 15),
          Text(
            "CHECKOUT",
            style: GoogleFonts.oswald(
              color: NeoColors.textHigh,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: NeoColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ORDER TOTAL",
                  style: GoogleFonts.oswald(
                    color: NeoColors.textLow,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  "₹${checkoutCrl.payableAmount.toStringAsFixed(0)}",
                  style: GoogleFonts.oswald(
                    color: NeoColors.accent,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "SHIPPING",
                  style: GoogleFonts.oswald(
                    color: NeoColors.textLow,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  "FREE",
                  style: GoogleFonts.oswald(
                    color: Colors.greenAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.1);
    });
  }

  Widget _shippingSection() {
    return Obx(() {
      final profile = profileCrl.profile.value;
      return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: NeoColors.surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "SHIPPING DESTINATION",
                      style: GoogleFonts.oswald(
                        color: NeoColors.textHigh,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.offNamed('/user-nav');
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (Get.isRegistered<UserNavController>()) {
                            Get.find<UserNavController>().changeTab(2);
                          }
                        });
                      },
                      child: Text(
                        "EDIT",
                        style: GoogleFonts.oswald(
                          color: NeoColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _infoRow(
                  Icons.location_on_rounded,
                  profile?.address.isNotEmpty == true
                      ? profile!.address
                      : "NO ADDRESS SET",
                  profile?.address.isNotEmpty != true,
                ),
                const SizedBox(height: 12),
                _infoRow(
                  Icons.phone_rounded,
                  profile?.phone.isNotEmpty == true
                      ? profile!.phone
                      : "NO PHONE NUMBER",
                  profile?.phone.isNotEmpty != true,
                ),
              ],
            ),
          )
          .animate()
          .fadeIn(delay: const Duration(milliseconds: 200))
          .slideY(begin: 0.1);
    });
  }

  Widget _infoRow(IconData icon, String text, bool isError) {
    return Row(
      children: [
        Icon(
          icon,
          color: isError ? NeoColors.error : NeoColors.accent,
          size: 18,
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.montserrat(
              color: isError ? NeoColors.error : NeoColors.textHigh,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _payButton() {
    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: NeoColors.premiumGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: NeoColors.accent.withOpacity(0.3),
            blurRadius: 20,
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
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          isLoading.value ? "WORKING..." : "PLACE ORDER",
          style: GoogleFonts.oswald(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    ).animate(delay: const Duration(milliseconds: 400)).fadeIn().scale();
  }
}
