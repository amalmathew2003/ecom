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

    // fetch cart AFTER first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartCtrl.fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bg,
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "My Cart",
                  style: TextStyle(
                    color: ColorConst.textLight,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            /// CART LIST
            Expanded(
              child: Obx(() {
                if (cartCtrl.cartItems.isEmpty) {
                  return const Center(
                    child: Text(
                      "Your cart is empty",
                      style: TextStyle(
                        color: ColorConst.textMuted,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  itemCount: cartCtrl.cartItems.length,
                  itemBuilder: (_, index) {
                    final item = cartCtrl.cartItems[index];
                    final product = item.product;

                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Get.to(
                          () => ProductDetailsScreen(product: product),
                          transition: Transition.cupertino,
                          duration: const Duration(milliseconds: 300),
                        );
                      },

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: ColorConst.card,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .25),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            /// IMAGE + QTY BADGE
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  Image.network(
                                    product.imageUrl.isNotEmpty
                                        ? product.imageUrl.first
                                        : 'https://via.placeholder.com/150',
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),

                                  Positioned(
                                    bottom: 6,
                                    right: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: .6,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "x${item.quantity}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 14),

                            /// PRODUCT INFO
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: ColorConst.textLight,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    "₹ ${item.total.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: ColorConst.price,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 2),

                                  Text(
                                    "₹ ${product.price} ",
                                    style: const TextStyle(
                                      color: ColorConst.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  /// QTY STEPPER
                                  _qtyStepper(item),
                                ],
                              ),
                            ),

                            /// DELETE
                            IconButton(
                              onPressed: () => cartCtrl.deleteItem(item.id),
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: ColorConst.danger.withValues(
                                    alpha: .12,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: ColorConst.danger,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),

      /// CHECKOUT BAR
      /// Replace the bottomNavigationBar block in CartScreen
      bottomNavigationBar: Obx(() {
        if (cartCtrl.cartItems.isEmpty) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          // Added SafeArea
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              // Use a Column with MainAxisSize.min
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final checkoutCtrl = Get.find<CheckoutController>();
                      checkoutCtrl.setCartChekout();
                      Get.to(() => const CheckoutScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConst.accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      "Checkout • ₹ ${cartCtrl.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// QTY STEPPER
  Widget _qtyStepper(item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(Icons.remove, () => cartCtrl.decreaseQty(item)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              item.quantity.toString(),
              style: const TextStyle(
                color: ColorConst.textLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _qtyBtn(Icons.add, () => cartCtrl.increaseQty(item)),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: ColorConst.accent),
      ),
    );
  }
}
