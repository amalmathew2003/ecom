import 'package:ecom/features/admin/products/controller/product_controller.dart';
import 'package:ecom/features/admin/products/ui/add_product_screen.dart';
import 'package:ecom/features/admin/products/ui/product_edit_screen.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:ecom/core/utils/responsive_layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminProductListScreen extends StatelessWidget {
  const AdminProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productCtrl = Get.find<AdminProductController>();

    return Scaffold(
      backgroundColor: NeoColors.background,
      body: ResponsiveLayout(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(() {
                if (productCtrl.isLoading.value &&
                    productCtrl.products.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: NeoColors.accent),
                  );
                }

                if (productCtrl.products.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: productCtrl.fetchProducts,
                  color: NeoColors.accent,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      if (width > 900) {
                        return _buildWebGrid(productCtrl);
                      }
                      return _buildMobileList(productCtrl);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
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
                "INVENTORY",
                style: GoogleFonts.oswald(
                  color: NeoColors.textHigh,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          _addButton(),
        ],
      ),
    );
  }

  Widget _addButton() {
    return ElevatedButton.icon(
      onPressed: () => Get.to(() => AdminAddProductPage()),
      icon: const Icon(Icons.add_rounded, size: 20),
      label: Text(
        "ADD PRODUCT",
        style: GoogleFonts.oswald(
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: NeoColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: NeoColors.textLow.withOpacity(0.2),
          ),
          const SizedBox(height: 20),
          Text(
            "NO PRODUCTS FOUND",
            style: GoogleFonts.oswald(
              color: NeoColors.textHigh,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 40),
          _addButton(),
        ],
      ),
    );
  }

  Widget _buildMobileList(AdminProductController ctrl) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: ctrl.products.length,
      itemBuilder: (context, index) => _productTile(ctrl.products[index], ctrl)
          .animate()
          .fadeIn(delay: Duration(milliseconds: index * 50))
          .slideY(begin: 0.1),
    );
  }

  Widget _buildWebGrid(AdminProductController ctrl) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 600,
        mainAxisExtent: 120, // Tighter height for product tiles in grid
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: ctrl.products.length,
      itemBuilder: (context, index) => _productTile(
        ctrl.products[index],
        ctrl,
      ).animate().fadeIn(delay: Duration(milliseconds: index * 30)).scale(),
    );
  }

  Widget _productTile(product, AdminProductController ctrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: NeoColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: NeoColors.background,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: product.imageUrl.isNotEmpty
                ? Image.network(product.imageUrl.first, fit: BoxFit.cover)
                : const Icon(
                    Icons.image_not_supported,
                    color: NeoColors.textLow,
                  ),
          ),
        ),
        title: Text(
          product.name.toUpperCase(),
          style: GoogleFonts.oswald(
            color: NeoColors.textHigh,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
        subtitle: Text(
          "STOCK: ${product.stock} | ₹${product.price}",
          style: GoogleFonts.montserrat(
            color: product.stock < 10 ? NeoColors.error : NeoColors.textMedium,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _actionBtn(
              Icons.edit_rounded,
              NeoColors.accent,
              () => Get.to(() => AdminEditProductPage(productId: product.id)),
            ),
            const SizedBox(width: 8),
            _actionBtn(
              Icons.delete_outline_rounded,
              NeoColors.error,
              () => _confirmDelete(product, ctrl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onTap,
      ),
    );
  }

  void _confirmDelete(product, AdminProductController ctrl) {
    Get.defaultDialog(
      backgroundColor: NeoColors.surface,
      title: "DELETE PRODUCT",
      titleStyle: GoogleFonts.oswald(
        color: NeoColors.textHigh,
        letterSpacing: 1,
      ),
      middleText: "Are you sure you want to remove ${product.name}?",
      middleTextStyle: GoogleFonts.montserrat(color: NeoColors.textLow),
      textConfirm: "DELETE",
      textCancel: "CANCEL",
      confirmTextColor: Colors.white,
      buttonColor: NeoColors.error,
      cancelTextColor: NeoColors.textLow,
      onConfirm: () {
        ctrl.deleteProduct(product.id);
        Get.back();
      },
    );
  }
}
