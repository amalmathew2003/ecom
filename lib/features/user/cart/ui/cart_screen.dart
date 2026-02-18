import 'package:flutter_animate/flutter_animate.dart';
import 'package:ecom/features/user/cart/controller/card_controller.dart';
import 'package:ecom/features/user/checkout/ui/checkout_screen.dart';
import 'package:ecom/features/user/checkout/controller/checkout_controller.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:ecom/core/utils/responsive_layout.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecom/core/routes/app_routes.dart';

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
      backgroundColor: NeoColors.background,
      body: Stack(
        children: [
          // 1. Kinetic Background
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          // 2. Ambient Orbs
          Positioned(
            top: -100,
            left: -100,
            child: _FloatingOrb(NeoColors.accent.withOpacity(0.1), 300),
          ),
          Positioned(
            bottom: 50,
            right: -50,
            child: _FloatingOrb(Colors.purpleAccent.withOpacity(0.05), 300),
          ),

          // 3. Main Content
          ResponsiveLayout(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Obx(() {
                      if (cartCtrl.cartItems.isEmpty) return _buildEmptyState();
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          if (ResponsiveLayout.isMobile(context)) {
                            return _buildMobileCartList();
                          }
                          return _buildWebCartLayout();
                        },
                      );
                    }),
                  ),
                  if (ResponsiveLayout.isMobile(context)) _checkoutBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "YOUR CART",
                  style: GoogleFonts.oswald(
                    color: NeoColors.textHigh,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ).animate().blur(
                  duration: const Duration(seconds: 1),
                  begin: const Offset(0, 5),
                ),
                Text(
                  "REVIEW ORDER",
                  style: GoogleFonts.oswald(
                    color: NeoColors.textLow,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Text(
                "${cartCtrl.cartItems.length} ITEMS",
                style: GoogleFonts.oswald(
                  color: NeoColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCartList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      itemCount: cartCtrl.cartItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (_, index) => _buildCartItem(cartCtrl.cartItems[index]),
    );
  }

  Widget _buildWebCartLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 10),
              itemCount: cartCtrl.cartItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (_, index) =>
                  _buildCartItem(cartCtrl.cartItems[index]),
            ),
          ),
          const SizedBox(width: 40),
          Expanded(flex: 1, child: _webSummaryPanel()),
        ],
      ),
    );
  }

  Widget _webSummaryPanel() {
    return Container(
      padding: const EdgeInsets.all(30),
      margin: const EdgeInsets.only(top: 10, bottom: 40),
      decoration: BoxDecoration(
        color: NeoColors.surface.withOpacity(0.8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SUMMARY",
            style: GoogleFonts.oswald(
              color: NeoColors.textHigh,
              fontSize: 20,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          _summaryRow(
            "SUBTOTAL",
            "₹${cartCtrl.totalAmount.toStringAsFixed(2)}",
          ),
          const SizedBox(height: 15),
          _summaryRow("SHIPPING", "FREE"),
          const Divider(height: 40, color: Colors.white10),
          _summaryRow(
            "TOTAL",
            "₹${cartCtrl.totalAmount.toStringAsFixed(2)}",
            isTotal: true,
          ),
          const SizedBox(height: 40),
          _payButton(isFullWidth: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.oswald(
            color: isTotal ? NeoColors.textHigh : NeoColors.textLow,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
            fontSize: isTotal ? 16 : 12,
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.oswald(
            color: isTotal ? NeoColors.accent : NeoColors.textHigh,
            fontSize: isTotal ? 24 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(item) {
    final product = item.product;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(product.imageUrl[0]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name.toUpperCase(),
                        style: GoogleFonts.oswald(
                          color: NeoColors.textHigh,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: NeoColors.textLow,
                        size: 20,
                      ),
                      onPressed: () => cartCtrl.deleteItem(item.id),
                    ),
                  ],
                ),
                Text(
                  "QTY: ${item.quantity}",
                  style: GoogleFonts.oswald(
                    color: NeoColors.textLow,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _qtyStepper(item),
                    Text(
                      "₹${item.total}",
                      style: GoogleFonts.oswald(
                        color: NeoColors.accent,
                        fontWeight: FontWeight.bold,
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
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 60,
            color: NeoColors.textLow.withOpacity(0.2),
          ),
          const SizedBox(height: 20),
          Text(
            "CART IS EMPTY",
            style: GoogleFonts.oswald(
              color: NeoColors.textHigh,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Start adding items to your cart",
            style: GoogleFonts.oswald(
              color: NeoColors.textLow,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 40),
          _actionButton("START SHOPPING", () => Get.back()),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _actionButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: NeoColors.textHigh,
        foregroundColor: NeoColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: const RoundedRectangleBorder(),
      ),
      child: Text(
        label,
        style: GoogleFonts.oswald(
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _checkoutBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 130),
      decoration: BoxDecoration(
        color: NeoColors.background,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "TOTAL",
                  style: GoogleFonts.oswald(
                    color: NeoColors.textLow,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Flexible(
                  child: Text(
                    "₹${cartCtrl.totalAmount.toStringAsFixed(2)}",
                    style: GoogleFonts.oswald(
                      color: NeoColors.textHigh,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          _payButton(),
        ],
      ),
    );
  }

  Widget _payButton({bool isFullWidth = false}) {
    return SizedBox(
      height: 60,
      width: isFullWidth ? double.infinity : 180,
      child: ElevatedButton(
        onPressed: () {
          if (Supabase.instance.client.auth.currentUser == null) {
            Get.toNamed(AppRoutes.login);
            Get.snackbar(
              'AUTH REQUIRED',
              'PLEASE LOGIN TO CONTINUE',
              backgroundColor: NeoColors.background,
              colorText: NeoColors.textHigh,
              snackPosition: SnackPosition.TOP,
              margin: const EdgeInsets.all(20),
              isDismissible: true,
              icon: const Icon(
                Icons.lock_outline_rounded,
                color: NeoColors.accent,
              ),
            );
            return;
          }
          final checkoutCtrl = Get.find<CheckoutController>();
          checkoutCtrl.setCartCheckout();
          Get.to(() => const CheckoutScreen());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: NeoColors.accent,
          foregroundColor: Colors.black,
          shape: const RoundedRectangleBorder(),
        ),
        child: Text(
          "PROCEED TO CHECKOUT",
          style: GoogleFonts.oswald(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _qtyStepper(item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          _qtyBtn(Icons.remove, () => cartCtrl.decreaseQty(item)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              item.quantity.toString(),
              style: GoogleFonts.oswald(
                color: NeoColors.textHigh,
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
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 16, color: NeoColors.textHigh),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    const spacing = 40.0;

    for (var i = 0.0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (var i = 0.0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FloatingOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _FloatingOrb(this.color, this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color, blurRadius: 100, spreadRadius: 20),
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.1, 1.1),
          duration: const Duration(seconds: 4),
        );
  }
}
