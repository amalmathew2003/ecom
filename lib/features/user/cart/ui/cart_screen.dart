import 'package:ecom/features/user/cart/controller/card_controller.dart';
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
    cartCtrl.fetchCart(); // ✅ CALL ONCE
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

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ColorConst.card,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          /// IMAGE
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              product.imageUrl.first,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 14),

                          /// INFO
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
                                    fontSize: 15,
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
                            icon: const Icon(
                              Icons.delete_outline,
                              color: ColorConst.danger,
                            ),
                            onPressed: () => cartCtrl.deleteItem(item.id),
                          ),
                        ],
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
      bottomNavigationBar: Obx(
        () => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorConst.card,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .35),
                blurRadius: 16,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: cartCtrl.cartItems.isEmpty ? null : () {},
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
        ),
      ),
    );
  }

  /// QTY STEPPER
  Widget _qtyStepper(item) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConst.surface,
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
        child: Icon(icon, size: 18, color: ColorConst.textLight),
      ),
    );
  }
}
