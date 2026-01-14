import 'package:ecom/features/user/cart/controller/card_controller.dart';
import 'package:ecom/features/user/profile/controller/profile_controller.dart';
import 'package:ecom/features/user/profile/data/profile_model.dart';
import 'package:ecom/service/checkout_service/checkout_controller.dart';
import 'package:ecom/service/checkout_service/checkout_mode.dart';
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
  void dispose() {
    razorpayService.dispose();
    super.dispose();
  }

  /// ================= START PAYMENT =================//
  void payment() {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      Get.snackbar("Error", "User not logged in");
      return;
    }

    if (profileCrl.profile.value == null ||
        profileCrl.profile.value!.phone.isEmpty) {
      _askPhoneNumber();
      return;
    }

    if (checkoutCrl.payableAmount <= 0) {
      Get.snackbar("Error", "Invalid amount");
      return;
    }

    /// ========================= INIT RAZORPAY ======================================///
    razorpayService.init(
      onSuccess: (paymentId) async {
        if (checkoutCrl.mode.value == CheckoutMode.cart) {
          await _placeCartOrder(paymentId);
        } else {
          await _placeBuyNowOrder(paymentId);
        }

        Get.snackbar("Success", "Order placed successfully");
        Get.back();
      },
      onError: (error) {
        Get.snackbar("Payment Failed", error);
      },
    );

    ///======================= OPEN CHECKOUT ============================///
    razorpayService.openChackout(
      amount: checkoutCrl.payableAmount,
      email: user.email ?? '',
      phone: profileCrl.profile.value!.phone,
    );
  }

  /// ================= ASK PHONE NUMBER =================///
  void _askPhoneNumber() {
    final phoneController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter Phone Number",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                hintText: "10-digit mobile number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final phone = phoneController.text.trim();

                  if (phone.length != 10) {
                    Get.snackbar('Invalid', 'Enter valid phone number');
                    return;
                  }

                  await _savePhone(phone);
                  Get.back();
                  payment(); // retry payment
                },
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= SAVE PHONE =================///
  Future<void> _savePhone(String phone) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    /// 1️⃣ Update phone in DB
    await Supabase.instance.client
        .from("profiles")
        .update({'phone': phone})
        .eq('id', user.id);

    /// 2️⃣ Update local state SAFELY
    final currentProfile = profileCrl.profile.value;

    if (currentProfile != null) {
      // profile already loaded → update it
      profileCrl.profile.value = currentProfile.copyWith(phone: phone);
    } else {
      // profile not loaded yet → create minimal profile
      profileCrl.profile.value = ProfileModel(
        id: user.id,
        email: user.email ?? '',
        fullName: '',
        phone: phone,
        role: 'user',
      );
    }
  }

  /// ================= CART ORDER =================
  Future<void> _placeCartOrder(String paymentId) async {
    await Supabase.instance.client.from('orders').insert({
      'user_id': cartCrl.userId,
      'amount': cartCrl.totalAmount,
      'payment_id': paymentId,
      'payment_method': "RAZORPAY",
      'payment_status': "SUCCESS",
      'order_type': "CART",
    });

    await Supabase.instance.client
        .from('cart')
        .delete()
        .eq('user_id', cartCrl.userId);

    cartCrl.cartItems.clear();
  }

  /// ================= BUY NOW ORDER =================
  Future<void> _placeBuyNowOrder(String paymentId) async {
    await Supabase.instance.client.from("orders").insert({
      'user_id': Supabase.instance.client.auth.currentUser!.id,
      'product_id': checkoutCrl.productId,
      'amount': checkoutCrl.buyNowAomunt,
      'payment_id': paymentId,
      'payment_method': "RAZORPAY",
      'payment_status': "SUCCESS",
      'order_type': "BUY_NOW",
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
        iconTheme: const IconThemeData(color: ColorConst.textLight),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= ORDER SUMMARY =================
            Obx(() {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ColorConst.card,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checkoutCrl.mode.value == CheckoutMode.cart
                          ? "Cart Checkout"
                          : "Buy Now",
                      style: const TextStyle(
                        color: ColorConst.textLight,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount",
                          style: TextStyle(color: ColorConst.textMuted),
                        ),
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
                  ],
                ),
              );
            }),

            const SizedBox(height: 26),

            /// ================= CUSTOMER DETAILS =================
            const Text(
              "Customer Details",
              style: TextStyle(
                color: ColorConst.textLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Obx(() {
              final profile = profileCrl.profile.value;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorConst.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.email_outlined,
                          size: 18,
                          color: ColorConst.textMuted,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Email",
                          style: TextStyle(color: ColorConst.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Supabase.instance.client.auth.currentUser?.email ?? '',
                      style: const TextStyle(color: ColorConst.textLight),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: const [
                        Icon(
                          Icons.phone_outlined,
                          size: 18,
                          color: ColorConst.textMuted,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Phone",
                          style: TextStyle(color: ColorConst.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.phone.isNotEmpty == true
                          ? profile!.phone
                          : "Not added",
                      style: const TextStyle(color: ColorConst.textLight),
                    ),
                  ],
                ),
              );
            }),

            const Spacer(),

            /// ================= PAY BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: payment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConst.accent,
                  foregroundColor: ColorConst.textDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 6,
                ),
                child: Obx(
                  () => Text(
                    checkoutCrl.mode.value == CheckoutMode.cart
                        ? "Pay & Checkout"
                        : "Pay & Buy Now",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
