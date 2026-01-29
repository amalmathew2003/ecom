import 'package:ecom/features/auth/controller/auth_controller.dart';
import 'package:ecom/features/user/home/controller/nav_category_chip_controller.dart';
import 'package:ecom/features/user/home/controller/product_controller.dart';
import 'package:ecom/features/user/home/controller/usersubcategory_controller.dart';
import 'package:ecom/features/user/home/ui/home/widget/category_chip.dart';
import 'package:ecom/features/user/home/ui/home/widget/new_arrivals_slider.dart';
import 'package:ecom/features/user/home/ui/home/widget/product_card.dart';
import 'package:ecom/features/user/profile/controller/profile_controller.dart';
import 'package:ecom/shared/models/product_model.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserHome extends StatelessWidget {
  UserHome({super.key});

  final AuthController auth = Get.find<AuthController>();
  final CategoryController categoryCtrl = Get.put(CategoryController());
  final UserSubCategoryController subCategoryCtrl = Get.put(
    UserSubCategoryController(),
  );
  final ProductController productCtrl = Get.put(ProductController());
  final ProfileController profileCtrl = Get.find<ProfileController>();
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🏷️ HEADER
            _buildHeader(),

            /// 🎨 NEW ARRIVALS
            _buildArrivals(),

            /// 📂 CATEGORIES
            _buildCategories(context),

            /// ✨ RECOMMENDATIONS
            _buildRecommendations(),

            /// 🛍️ POPULAR PRODUCTS (OR SEARCH RESULTS)
            _buildProductSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NeoMart',
                    style: TextStyle(
                      color: ColorConst.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  Obx(() {
                    final name = profileCtrl.profile.value?.fullName ?? 'User';
                    return Text(
                      'Hey $name, find your style 👋',
                      style: const TextStyle(
                        color: ColorConst.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),
                ],
              ),
              _circleBtn(Icons.notifications_active_rounded),
            ],
          ),
          const SizedBox(height: 24),

          /// SEARCH BAR
          Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: ColorConst.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ColorConst.surface, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: ColorConst.textMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (val) => productCtrl.searchProducts(val),
                    style: const TextStyle(color: ColorConst.textLight),
                    decoration: const InputDecoration(
                      hintText: 'Search for luxury products...',
                      hintStyle: TextStyle(
                        color: ColorConst.textMuted,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      searchController.clear();
                      productCtrl.fetchProducts();
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      color: ColorConst.textMuted,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrivals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            "New Arrivals",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ProductCarousel(),
      ],
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trend Clusters',
                style: TextStyle(
                  color: ColorConst.textLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Refine",
                  style: TextStyle(color: ColorConst.primary),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 48,
          child: Obx(() {
            final selectedIndex = categoryCtrl.selectedIndex.value;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: categoryCtrl.categories.length,
              itemBuilder: (_, index) {
                final cat = categoryCtrl.categories[index];
                return CategoryChip(
                  title: cat['name'],
                  isSelected: selectedIndex == index,
                  onTap: () {
                    categoryCtrl.select(index);
                    productCtrl.fetchProducts(categoryId: cat['id'].toString());
                    subCategoryCtrl.fetchSubCategories(cat['id'].toString());
                  },
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildProductSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: Text(
            'Curated For You',
            style: TextStyle(
              color: ColorConst.textLight,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Obx(() {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Skeletonizer(
              enabled: productCtrl.isLoading.value,
              child: GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: productCtrl.isLoading.value
                    ? 6
                    : productCtrl.products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (_, i) {
                  final product = productCtrl.isLoading.value
                      ? ProductModel.skeleton()
                      : productCtrl.products[i];
                  return ProductCard(product: product);
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: Text(
            'Exclusive Picks',
            style: TextStyle(
              color: ColorConst.textLight,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        SizedBox(
          height: 280,
          child: Obx(() {
            if (productCtrl.recommendedProducts.isEmpty)
              return const Center(
                child: Text(
                  "Curating best picks...",
                  style: TextStyle(color: ColorConst.textMuted),
                ),
              );
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: productCtrl.recommendedProducts.length,
              itemBuilder: (context, index) {
                final product = productCtrl.recommendedProducts[index];
                return Container(
                  width: 170,
                  margin: const EdgeInsets.only(right: 16),
                  child: ProductCard(product: product),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _circleBtn(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConst.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConst.surface),
      ),
      child: IconButton(
        icon: Icon(icon, color: ColorConst.textLight, size: 22),
        onPressed: () {},
      ),
    );
  }
}
