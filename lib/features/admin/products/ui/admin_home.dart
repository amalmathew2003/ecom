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
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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

          /// ADD BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
                onPressed: () {
                  Get.to(
                    () => AdminAddProductPage(),
                  )!.then((_) => productCtrl.fetchProducts());
                },
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.category),
                label: const Text('Add Category'),
                onPressed: () {
                  Get.to(() => AdminAddCategoryPage());
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// PRODUCT LIST
          Expanded(
            child: Obx(() {
              if (productCtrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (productCtrl.products.isEmpty) {
                return const Center(child: Text("No products found"));
              }

              return ListView.builder(
                itemCount: productCtrl.products.length,
                itemBuilder: (context, index) {
                  final product = productCtrl.products[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          product.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(product.name),
                      subtitle: Text(
                        "₹${product.price}\n${product.description}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// EDIT
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Get.to(
                                () => AdminEditProductPage(product: product),
                              );
                            },
                          ),

                          /// DELETE
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final success = await productCtrl.deleteProduct(
                                product.id,
                              );

                              if (!success) {
                                Get.snackbar(
                                  'Failed',
                                  'Delete failed (RLS or ID issue)',
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
}
