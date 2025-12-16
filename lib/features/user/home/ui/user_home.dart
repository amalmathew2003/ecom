import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecom/core/routes/app_routes.dart';
import 'package:ecom/features/auth/controller/auth_controller.dart';
import 'package:ecom/features/user/home/controller/nav_category_chip_controller.dart';
import 'package:ecom/features/user/home/controller/product_controller.dart';
import 'package:ecom/features/user/home/ui/widget/category_chip.dart';
import 'package:ecom/features/user/home/ui/widget/new_arrivals_slider.dart';
import 'package:ecom/features/user/home/ui/widget/product_card.dart';
import 'package:ecom/shared/widgets/const/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserHome extends StatelessWidget {
  UserHome({super.key});

  final AuthController auth = Get.find<AuthController>();
  final CategoryController categoryCtrl = Get.put(CategoryController());
  final ProductController productCtrl = Get.put(ProductController());

  final List<String> categories = const [
    'All',
    'Electronics',
    'Fashion',
    'Shoes',
    'Accessories',
  ];

  /// 🔹 SLIDER IMAGES
  final List<String> sliderListImage = const [
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e',
    'https://images.unsplash.com/photo-1512436991641-6745cdb1723f',
  ];

  /// 🔹 SLIDER TITLES
  final List<String> sliderTitles = const [
    'Big Sale 🔥',
    'New Arrivals',
    'Trending Products',
  ];

  @override
  Widget build(BuildContext context) {
    final height = ScreenSize.height(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      /// 🔹 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'E-Commerce',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Get.offAllNamed(AppRoutes.login);
            },
          ),
        ],
      ),

      /// 🔹 BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ==========================
            /// 🔥 PROMO SLIDER
            /// ==========================
            const Text(
              'New Arrivals',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            ProductCarousel(),

            const SizedBox(height: 28),

            const SizedBox(height: 28),

            /// ==========================
            /// 🔹 CATEGORIES
            /// ==========================
            const Text(
              'Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Obx(
                    () => CategoryChip(
                      title: categories[index],
                      isSelected: categoryCtrl.selectedIndex.value == index,
                      onTap: () {
                        categoryCtrl.select(index);
                        productCtrl.fetchProducts(category: categories[index]);
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            /// ==========================
            /// 🔹 PRODUCTS
            /// ==========================
            const Text(
              'Popular Products',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            Obx(() {
              if (productCtrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (productCtrl.products.isEmpty) {
                return const Center(child: Text('No products found'));
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: productCtrl.products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (_, index) {
                  final product = productCtrl.products[index];
                  return ProductCard(product: product);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
