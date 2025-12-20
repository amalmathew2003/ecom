import 'package:ecom/core/routes/app_routes.dart';
import 'package:ecom/features/auth/controller/auth_controller.dart';
import 'package:ecom/features/user/home/controller/nav_category_chip_controller.dart';
import 'package:ecom/features/user/home/controller/product_controller.dart';
import 'package:ecom/features/user/home/controller/usersubcategory_controller.dart';
import 'package:ecom/features/user/home/ui/home/widget/category_chip.dart';
import 'package:ecom/features/user/home/ui/home/widget/new_arrivals_slider.dart';
import 'package:ecom/features/user/home/ui/home/widget/product_card.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserHome extends StatelessWidget {
  UserHome({super.key});

  final AuthController auth = Get.find<AuthController>();
  final CategoryController categoryCtrl = Get.put(CategoryController());
  final UserSubCategoryController subCategoryCtrl = Get.put(
    UserSubCategoryController(),
  );
  final ProductController productCtrl = Get.put(ProductController());

  /// ==========================
  /// CATEGORY BOTTOM SHEET
  void _showCategorySheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: ColorConst.card,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(() {
            return GridView.builder(
              itemCount: categoryCtrl.categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (_, index) {
                final cat = categoryCtrl.categories[index];

                return GestureDetector(
                  onTap: () {
                    categoryCtrl.select(index);
                    final categoryId = cat['id'].toString();
                    productCtrl.fetchProducts(categoryId: categoryId);
                    subCategoryCtrl.fetchSubCategories(categoryId);
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 50,
                        decoration: BoxDecoration(
                          color: ColorConst.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            cat['name'][0].toUpperCase(),
                            style: const TextStyle(
                              color: ColorConst.accent,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat['name'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: ColorConst.textLight,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }

  /// ==========================
  /// FILTER SHEET
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: ColorConst.card,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sort & Filter',
                style: TextStyle(
                  color: ColorConst.textLight,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text(
                  'Price: Low to High',
                  style: TextStyle(color: ColorConst.textLight),
                ),
                onTap: () {
                  productCtrl.sortByPriceLowToHigh();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text(
                  'Price: High to Low',
                  style: TextStyle(color: ColorConst.textLight),
                ),
                onTap: () {
                  productCtrl.sortByPriceHighToLow();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bg,

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
              decoration: const BoxDecoration(
                color: ColorConst.navy,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'NeoMart',
                        style: TextStyle(
                          color: ColorConst.accent,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Welcome 👋',
                        style: TextStyle(
                          color: ColorConst.textMuted,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: ColorConst.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: ColorConst.accent),
                      onPressed: () async {
                        await auth.logout();
                        Get.offAllNamed(AppRoutes.login);
                      },
                    ),
                  ),
                ],
              ),
            ),

            /// NEW ARRIVALS
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ProductCarousel(),
            ),

            /// CATEGORIES
            _SectionCard(
              title: 'Browse Categories',
              actionText: 'Explore',
              onActionTap: () => _showCategorySheet(context),
              child: SizedBox(
                height: 50,
                child: Obx(() {
                  final selectedIndex = categoryCtrl.selectedIndex.value;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categoryCtrl.categories.length,
                    itemBuilder: (context, index) {
                      final cat = categoryCtrl.categories[index];

                      return CategoryChip(
                        title: cat['name'],
                        isSelected: selectedIndex == index, // ✅ works
                        onTap: () {
                          categoryCtrl.select(index); // ✅ updates
                          final categoryId = cat['id'].toString();
                          productCtrl.fetchProducts(categoryId: categoryId);
                          subCategoryCtrl.fetchSubCategories(categoryId);
                        },
                      );
                    },
                  );
                }),
              ),
            ),

            /// SUB CATEGORIES
            Obx(() {
              if (subCategoryCtrl.subCategories.isEmpty) {
                return const SizedBox();
              }
              return _SectionCard(
                title: 'Refine by',
                actionText: 'Filter',
                onActionTap: () => _showFilterSheet(context),
                child: SizedBox(
                  height: 44,
                  child: Obx(() {
                    final selected = subCategoryCtrl.selectedIndex.value;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: subCategoryCtrl.subCategories.length,
                      itemBuilder: (context, index) {
                        final sub = subCategoryCtrl.subCategories[index];

                        return CategoryChip(
                          title: sub['name'],
                          isSelected: selected == index, // ✅ FIXED
                          onTap: () {
                            subCategoryCtrl.select(index); // ✅ updates state

                            productCtrl.fetchProductsBySubCategory(
                              subCategoryId: sub['id'].toString(),
                            );
                          },
                        );
                      },
                    );
                  }),
                ),
              );
            }),

            /// PRODUCTS
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Popular Products',
                style: TextStyle(
                  color: ColorConst.textLight,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Obx(() {
              if (productCtrl.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: ColorConst.accent),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: productCtrl.products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (_, i) {
                    return ProductCard(product: productCtrl.products[i]);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// ==========================
/// SECTION CARD (DARK)
class _SectionCard extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? onActionTap;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.actionText,
    required this.child,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConst.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: ColorConst.textLight,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: onActionTap,
                child: Text(
                  actionText,
                  style: const TextStyle(
                    color: ColorConst.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
