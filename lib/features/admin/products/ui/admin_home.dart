import 'package:ecom/features/admin/products/controller/product_controller.dart';
import 'package:ecom/features/admin/products/ui/add_product_screen.dart';
import 'package:ecom/features/admin/products/ui/category_add_screen.dart';
import 'package:ecom/features/admin/products/ui/product_edit_screen.dart';
import 'package:ecom/features/auth/data/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late final AdminProductController productCtrl;

  @override
  void initState() {
    super.initState();
    productCtrl = Get.put(AdminProductController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      productCtrl.fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return Scaffold(
      backgroundColor: const Color(0xFF192230),

      /// APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF192230),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.4),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFFFCD00)),
            onPressed: () {
              auth.logout();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 16),

          /// ACTION BUTTONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _actionButton(
                    icon: Icons.add,
                    label: 'Add Product',
                    onTap: () {
                      Get.to(
                        () => AdminAddProductPage(),
                      )?.then((_) => productCtrl.fetchProducts());
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionButton(
                    icon: Icons.category,
                    label: 'Add Category',
                    onTap: () {
                      Get.to(() => AdminAddCategoryPage());
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// PRODUCT LIST
          Expanded(
            child: Obx(() {
              if (productCtrl.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFFCD00)),
                );
              }

              if (productCtrl.products.isEmpty) {
                return const Center(
                  child: Text(
                    "No products found",
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: productCtrl.products.length,
                itemBuilder: (context, index) {
                  final product = productCtrl.products[index];
                  final image = product.imageUrl.isNotEmpty
                      ? product.imageUrl.first
                      : null;

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2F38),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),

                      /// IMAGE
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: image != null
                            ? Image.network(
                                image,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _imageFallback(),
                              )
                            : _imageFallback(),
                      ),

                      /// TEXT
                      title: Text(
                        product.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "₹${product.price}\n${product.description}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFB0B6BE),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      isThreeLine: true,

                      /// ACTIONS
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _iconAction(
                            icon: Icons.edit,
                            color: const Color(0xFFFFCD00),
                            onTap: () {
                              Get.to(
                                () =>
                                    AdminEditProductPage(productId: product.id),
                              );
                            },
                          ),
                          _iconAction(
                            icon: Icons.delete,
                            color: Colors.redAccent,
                            onTap: () async {
                              final success = await productCtrl.deleteProduct(
                                product.id,
                              );

                              if (!success) {
                                Get.snackbar(
                                  'Failed',
                                  'Delete failed',
                                  snackPosition: SnackPosition.TOP,
                                );
                              }
                            },
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
    );
  }

  /// ACTION BUTTON
  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFFFCD00),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ICON ACTION
  Widget _iconAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onTap,
    );
  }

  Widget _imageFallback() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.white70,
        size: 20,
      ),
    );
  }
}
