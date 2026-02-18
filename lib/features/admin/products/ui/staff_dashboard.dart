import 'package:ecom/features/admin/orders/controller/admin_order_controller.dart';
import 'package:ecom/features/admin/orders/ui/staff_order_screen.dart';
import 'package:ecom/features/admin/products/controller/product_controller.dart';
import 'package:ecom/features/admin/products/ui/add_product_screen.dart';
import 'package:ecom/features/admin/products/ui/category_add_screen.dart';
import 'package:ecom/features/admin/products/ui/product_edit_screen.dart';
import 'package:ecom/features/auth/controller/auth_controller.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:ecom/core/utils/responsive_layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final orderCtrl = Get.put(AdminOrderController());
    final productCtrl = Get.put(AdminProductController());
    final authCtrl = Get.find<AuthController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderCtrl.fetchAllOrders();
      productCtrl.fetchProducts();
    });

    return Scaffold(
      backgroundColor: NeoColors.background,
      body: ResponsiveLayout(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(authCtrl),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (ResponsiveLayout.isMobile(context)) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatsRow(orderCtrl, productCtrl),
                          const SizedBox(height: 30),
                          _buildMainAction(),
                          const SizedBox(height: 20),
                          _buildSecondaryActions(),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              _buildStatsRow(orderCtrl, productCtrl),
                              const SizedBox(height: 40),
                              _sectionHeader("RECENT INVENTORY"),
                              _buildMiniProductList(productCtrl),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildMainAction(),
                              const SizedBox(height: 20),
                              _buildSecondaryActions(),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            if (ResponsiveLayout.isMobile(context)) ...[
              SliverToBoxAdapter(child: _sectionHeader("RECENT INVENTORY")),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: _buildMiniProductList(productCtrl),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(AuthController auth) {
    return SliverAppBar(
      backgroundColor: NeoColors.background,
      floating: true,
      pinned: true,
      toolbarHeight: 100,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "OPERATIONS CONSOLE",
            style: GoogleFonts.oswald(
              color: NeoColors.accent,
              fontSize: 12,
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "STAFF DASHBOARD",
            style: GoogleFonts.oswald(
              color: NeoColors.textHigh,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: NeoColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: IconButton(
            onPressed: () => auth.logout(),
            icon: const Icon(Icons.logout_rounded, color: NeoColors.error),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(
    AdminOrderController orderCtrl,
    AdminProductController productCtrl,
  ) {
    return Obx(
      () => Row(
        children: [
          _statTile(
            "PENDING",
            orderCtrl.orders
                .where((o) => o.status == 'PENDING')
                .length
                .toString(),
            Icons.pending_actions_rounded,
            Colors.orangeAccent,
          ),
          const SizedBox(width: 15),
          _statTile(
            "STOCK",
            productCtrl.products.length.toString(),
            Icons.inventory_2_rounded,
            NeoColors.accent,
          ),
          const SizedBox(width: 15),
          _statTile(
            "SUCCESS",
            orderCtrl.orders
                .where((o) => o.status == 'SUCCESS')
                .length
                .toString(),
            Icons.check_circle_rounded,
            Colors.greenAccent,
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _statTile(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: NeoColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.1), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.oswald(
                color: NeoColors.textHigh,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.montserrat(
                color: NeoColors.textLow,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainAction() {
    return InkWell(
          onTap: () => Get.to(() => StaffOrderScreen()),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: NeoColors.premiumGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: NeoColors.accent.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ORDER FULFILLMENT",
                        style: GoogleFonts.oswald(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        "PROCESS & ASSIGN SHIPMENTS",
                        style: GoogleFonts.montserrat(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 200))
        .slideX(begin: 0.1);
  }

  Widget _buildSecondaryActions() {
    return Row(
          children: [
            Expanded(
              child: _actionBtn(
                "ADD PRODUCT",
                Icons.add_box_rounded,
                NeoColors.accent,
                () => Get.to(() => AdminAddProductPage()),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _actionBtn(
                "CATEGORIES",
                Icons.category_rounded,
                Colors.purpleAccent,
                () => Get.to(() => AdminAddCategoryPage()),
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 400))
        .slideX(begin: 0.1);
  }

  Widget _actionBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: NeoColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.oswald(
                color: NeoColors.textHigh,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniProductList(AdminProductController ctrl) {
    return Obx(() {
      final items = ctrl.products.take(6).toList();
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final product = items[index];
          return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: NeoColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.03)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.imageUrl.first,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    product.name.toUpperCase(),
                    style: GoogleFonts.oswald(
                      color: NeoColors.textHigh,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "STOCK: ${product.stock}",
                    style: GoogleFonts.montserrat(
                      color: product.stock < 10
                          ? NeoColors.error
                          : Colors.greenAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () => Get.to(
                      () => AdminEditProductPage(productId: product.id),
                    ),
                    icon: const Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: NeoColors.accent,
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: Duration(milliseconds: index * 50))
              .slideY(begin: 0.1);
        },
      );
    });
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
      child: Text(
        title,
        style: GoogleFonts.oswald(
          color: NeoColors.textLow,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
