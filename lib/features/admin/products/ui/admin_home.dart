import 'package:ecom/features/admin/products/ui/add_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Welcome Admin',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can manage products and orders here',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            /// 🔹 Add Product Button
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
              onPressed: () {
                Get.to(() => AdminAddProductPage());
              },
            ),
          ],
        ),
      ),
    );
  }
}
