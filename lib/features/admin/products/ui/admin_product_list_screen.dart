import 'package:ecom/features/admin/products/controller/product_controller.dart';
import 'package:ecom/features/admin/products/ui/add_product_screen.dart';
import 'package:ecom/features/admin/products/ui/product_edit_screen.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminProductListScreen extends StatelessWidget {
  const AdminProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productCtrl = Get.find<AdminProductController>();

    return Scaffold(
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Inventory Management',
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
        actions: [
          IconButton(
            onPressed: () => Get.to(() => AdminAddProductPage()),
            icon: const Icon(Icons.add_box_rounded, color: ColorConst.primary),
          ),
        ],
      ),
      body: Obx(() {
        if (productCtrl.isLoading.value && productCtrl.products.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: ColorConst.primary),
          );
        }

        if (productCtrl.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: ColorConst.textMuted.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No products found",
                  style: TextStyle(color: ColorConst.textMuted),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: productCtrl.fetchProducts,
          color: ColorConst.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: productCtrl.products.length,
            itemBuilder: (context, index) {
              final product = productCtrl.products[index];
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
                      product.imageUrl.isNotEmpty
                          ? product.imageUrl.first
                          : 'https://via.placeholder.com/150',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(
                      color: ColorConst.textLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Stock: ${product.stock} | ₹${product.price}",
                    style: TextStyle(
                      color: product.stock < 10
                          ? Colors.redAccent
                          : ColorConst.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_rounded,
                          color: ColorConst.primary,
                          size: 20,
                        ),
                        onPressed: () => Get.to(
                          () => AdminEditProductPage(productId: product.id),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        onPressed: () {
                          Get.defaultDialog(
                            title: "Delete Product",
                            middleText:
                                "Are you sure you want to delete ${product.name}?",
                            backgroundColor: ColorConst.card,
                            titleStyle: const TextStyle(
                              color: ColorConst.textLight,
                            ),
                            middleTextStyle: const TextStyle(
                              color: ColorConst.textMuted,
                            ),
                            textConfirm: "Delete",
                            textCancel: "Cancel",
                            confirmTextColor: Colors.white,
                            buttonColor: Colors.redAccent,
                            onConfirm: () {
                              productCtrl.deleteProduct(product.id);
                              Get.back();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
