import 'package:animate_do/animate_do.dart';
import 'package:ecom/features/user/cart/controller/card_controller.dart';
import 'package:ecom/features/user/checkout/ui/checkout_screen.dart';
import 'package:ecom/features/user/checkout/controller/checkout_controller.dart';
import 'package:ecom/features/user/home/ui/product_details/product_details_screen.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController cartCtrl = Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartCtrl.fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            /// 🏷️ CUSTOM PREMIUM HEADER
            _buildHeader(),

            /// 🛒 CART LIST
            Expanded(
              child: Obx(() {
                if (cartCtrl.cartItems.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  itemCount: cartCtrl.cartItems.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (_, index) {
                    final item = cartCtrl.cartItems[index];
                    return FadeInRight(
                      delay: Duration(milliseconds: index * 100),
                      duration: const Duration(milliseconds: 500),
                      child: _buildCartItem(item),
                    );
                  },
                );
              }),
            ),

            /// 💰 FLOATING CHECKOUT BAR
            _checkoutBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FadeInDown(
                child: const Text(
                  "Shopping Bag",
                  style: TextStyle(
                    color: ColorConst.textLight,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
              ),
              Obx(
                () => FadeIn(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ColorConst.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: ColorConst.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      "${cartCtrl.cartItems.length} Items",
                      style: const TextStyle(
                        color: ColorConst.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: Text(
              "Check your items and proceed to payment",
              style: TextStyle(
                color: ColorConst.textMuted.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(item) {
    final product = item.product;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: ColorConst.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: ColorConst.surface.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Get.to(() => ProductDetailsScreen(product: product)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  /// 🖼️ PRODUCT IMAGE with Gradient Overlay
                  Stack(
                    children: [
                      Hero(
                        tag: "${product.id}_cart",
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            product.imageUrl.isNotEmpty
                                ? product.imageUrl.first
                                : 'https://via.placeholder.com/150',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 18),

                  /// 📄 INFO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: ColorConst.textLight,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => cartCtrl.deleteItem(item.id),
                              child: Icon(
                                Icons.remove_circle_outline_rounded,
                                color: ColorConst.danger.withValues(alpha: 0.7),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Price per unit: ₹${product.price}",
                          style: TextStyle(
                            color: ColorConst.textMuted.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _qtyStepper(item),
                            Text(
                              "₹${item.total}",
                              style: const TextStyle(
                                color: ColorConst.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: ColorConst.card,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorConst.primary.withValues(alpha: 0.1),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                color: ColorConst.textMuted.withValues(alpha: 0.3),
                size: 80,
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            child: Column(
              children: [
                const Text(
                  "Your bag is empty",
                  style: TextStyle(
                    color: ColorConst.textLight,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Add some products to your bag\nand they will appear here",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColorConst.textMuted.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                "Continue Shopping",
                style: TextStyle(
                  color: ColorConst.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkoutBar() {
    return Obx(() {
      if (cartCtrl.cartItems.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        decoration: BoxDecoration(
          color: ColorConst.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 40,
              offset: const Offset(0, -10),
            ),
          ],
          border: Border.all(color: ColorConst.surface.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Amount",
                      style: TextStyle(
                        color: ColorConst.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹ ${cartCtrl.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: ColorConst.textLight,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                _payButton(),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _payButton() {
    return Container(
      height: 60,
      width: 170,
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
        onPressed: () {
          final checkoutCtrl = Get.find<CheckoutController>();
          checkoutCtrl.setCartCheckout();
          Get.to(() => const CheckoutScreen());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          "Checkout",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _qtyStepper(item) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColorConst.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(Icons.remove_rounded, () => cartCtrl.decreaseQty(item)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              item.quantity.toString(),
              style: const TextStyle(
                color: ColorConst.textLight,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
          _qtyBtn(Icons.add_rounded, () => cartCtrl.increaseQty(item)),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: ColorConst.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 16, color: ColorConst.primary),
      ),
    );
  }
}
