import 'package:ecom/features/admin/orders/controller/admin_order_controller.dart';
import 'package:ecom/features/admin/orders/ui/staff_order_screen.dart';
import 'package:ecom/features/admin/products/controller/product_controller.dart';
import 'package:ecom/features/admin/products/ui/add_product_screen.dart';
import 'package:ecom/features/admin/products/ui/admin_product_list_screen.dart';
import 'package:ecom/features/admin/products/ui/category_add_screen.dart';
import 'package:ecom/features/admin/products/ui/product_edit_screen.dart';
import 'package:ecom/features/auth/controller/auth_controller.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final orderCtrl = Get.put(AdminOrderController());
    final productCtrl = Get.put(AdminProductController());
    final authCtrl = Get.find<AuthController>();

    // Refresh data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderCtrl.fetchAllOrders();
      productCtrl.fetchProducts();
    });

    return Scaffold(
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'STAFF CONSOLE',
              style: TextStyle(
                color: ColorConst.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const Text(
              'Store Operations',
              style: TextStyle(
                color: ColorConst.textLight,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => authCtrl.logout(),
            icon: const Icon(Icons.logout_rounded, color: ColorConst.danger),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 📦 OPERATIONAL STATS
            _buildStatsGrid(orderCtrl, productCtrl),

            const SizedBox(height: 32),

            /// 🏪 INVENTORY ACTIONS (Staff Duty)
            _sectionHeader("Inventory & Catalog"),
            _buildInventoryRow(),

            const SizedBox(height: 24),

            /// 🚚 LOGISTICS
            _sectionHeader("Shipments & Deliveries"),
            _buildLogisticsTile(),

            const SizedBox(height: 32),

            /// 📦 LIVE INVENTORY OVERVIEW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionHeader("Recent Products"),
                Padding(
                  padding: const EdgeInsets.only(right: 20, bottom: 12),
                  child: TextButton(
                    onPressed: () =>
                        Get.to(() => const AdminProductListScreen()),
                    child: const Text(
                      "View All",
                      style: TextStyle(color: ColorConst.primary, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            _buildMiniProductList(productCtrl),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(orderCtrl, productCtrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(
        () => Row(
          children: [
            _statCard(
              "Pending",
              orderCtrl.orders
                  .where((o) => o.status == 'PENDING')
                  .length
                  .toString(),
              Icons.pending_actions_rounded,
              Colors.orangeAccent,
            ),
            const SizedBox(width: 12),
            _statCard(
              "Stock Items",
              productCtrl.products.length.toString(),
              Icons.inventory_2_rounded,
              ColorConst.primary,
            ),
            const SizedBox(width: 12),
            _statCard(
              "Success",
              orderCtrl.orders
                  .where((o) => o.status == 'SUCCESS')
                  .length
                  .toString(),
              Icons.check_circle_rounded,
              Colors.greenAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _actionTile(
              "Add Product",
              Icons.add_box_rounded,
              ColorConst.primary,
              () => Get.to(() => AdminAddProductPage()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _actionTile(
              "Categories",
              Icons.category_rounded,
              const Color(0xFF6366F1),
              () => Get.to(() => AdminAddCategoryPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogisticsTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => Get.to(() => StaffOrderScreen()),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorConst.primary,
                ColorConst.primary.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: ColorConst.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order Fulfillment",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Process shipments & track orders",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
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
      ),
    );
  }

  Widget _buildMiniProductList(productCtrl) {
    return Obx(() {
      if (productCtrl.isLoading.value && productCtrl.products.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: ColorConst.primary),
        );
      }
      final items = productCtrl.products.take(5).toList();
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final product = items[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: ColorConst.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ColorConst.surface, width: 1.5),
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
                product.name,
                style: const TextStyle(
                  color: ColorConst.textLight,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Row(
                children: [
                  Text(
                    "Stock: ",
                    style: const TextStyle(
                      color: ColorConst.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "${product.stock}",
                    style: TextStyle(
                      color: product.stock < 10
                          ? Colors.redAccent
                          : Colors.greenAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: Container(
                decoration: BoxDecoration(
                  color: ColorConst.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.edit_rounded,
                    size: 18,
                    color: ColorConst.primary,
                  ),
                  onPressed: () =>
                      Get.to(() => AdminEditProductPage(productId: product.id)),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          color: ColorConst.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorConst.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: ColorConst.textLight,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: ColorConst.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(
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
          color: ColorConst.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: ColorConst.surface, width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: ColorConst.textLight,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
