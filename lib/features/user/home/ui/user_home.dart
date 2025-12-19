import 'package:ecom/core/routes/app_routes.dart';
import 'package:ecom/features/auth/controller/auth_controller.dart';
import 'package:ecom/features/user/home/controller/nav_category_chip_controller.dart';
import 'package:ecom/features/user/home/controller/product_controller.dart';
import 'package:ecom/features/user/home/controller/usersubcategory_controller.dart';
import 'package:ecom/features/user/home/ui/widget/category_chip.dart';
import 'package:ecom/features/user/home/ui/widget/new_arrivals_slider.dart';
import 'package:ecom/features/user/home/ui/widget/product_card.dart';
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
  /// Explore SHOW CATEGORY BOTTOM SHEET
  void _showCategorySheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: ColorConst.ivory,
      context: context,
      isScrollControlled: true,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: ColorConst.navy,
                        ),
                        child: Center(
                          child: Text(
                            cat['name'][0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      Text(
                        cat['name'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: ColorConst.textDark,
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
  } ///////////////////////////////////

  /// ==========================Show Filter CATEGORY BOTTOM SHEET
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort & Filter',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorConst.navy,
                ),
              ),
              const SizedBox(height: 20),

              ListTile(
                title: const Text(
                  'Price: Low to High',
                  style: TextStyle(color: ColorConst.textDark),
                ),
                onTap: () {
                  productCtrl.sortByPriceLowToHigh();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Price: High to Low',                  style: TextStyle(color: ColorConst.textDark),
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
      backgroundColor: ColorConst.accent,

      /// ==========================
      /// BODY
      /// ==========================
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ==========================
            /// MODERN HEADER (REPLACES APP BAR)
            /// ==========================
            Container(
              padding: const EdgeInsets.fromLTRB(16, 38, 16, 20),
              decoration: BoxDecoration(
                color: ColorConst.navy,

                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// APP NAME
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NeoMart',
                        style: TextStyle(
                          color: ColorConst.accent,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Welcome 👋',
                        style: TextStyle(
                          color: ColorConst.ivory.withValues(alpha: 0.8),
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),

                  /// LOGOUT BUTTON
                  Container(
                    decoration: BoxDecoration(
                      color: ColorConst.ivory,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      tooltip: 'Logout',
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: ColorConst.navy,
                      ),
                      onPressed: () async {
                        await auth.logout();
                        Get.offAllNamed(AppRoutes.login);
                      },
                    ),
                  ),
                ],
              ),
            ),

            /// ==========================
            /// HERO / NEW ARRIVALS
            /// ==========================
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ProductCarousel(),
            ),

            /// ==========================
            /// 🔹 CATEGORIES
            /// ==========================
            _SectionCard(
              title: 'Browse Categories',
              actionText: 'Explore',
              onActionTap: () {
                _showCategorySheet(context);
              },
              child: SizedBox(
                height: 50,
                child: Obx(() {
                  if (categoryCtrl.categories.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categoryCtrl.categories.length,
                    itemBuilder: (context, index) {
                      final cat = categoryCtrl.categories[index];

                      return Obx(
                        () => CategoryChip(
                          title: cat['name'],
                          isSelected: categoryCtrl.selectedIndex.value == index,
                          onTap: () {
                            categoryCtrl.select(index);

                            final categoryId = cat['id'].toString();

                            productCtrl.fetchProducts(categoryId: categoryId);
                            subCategoryCtrl.fetchSubCategories(categoryId);
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ),

            /// ==========================
            /// 🔹 SUB-CATEGORIES (SMART)
            /// ==========================
            Obx(() {
              if (subCategoryCtrl.subCategories.isEmpty) {
                return const SizedBox();
              }

              return _SectionCard(
                title: 'Refine by',
                actionText: 'Filter',
                onActionTap: () {
                  _showFilterSheet(context);
                },

                child: SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: subCategoryCtrl.subCategories.length,
                    itemBuilder: (context, index) {
                      final sub = subCategoryCtrl.subCategories[index];

                      return Obx(
                        () => CategoryChip(
                          title: sub['name'],
                          isSelected:
                              subCategoryCtrl.selectedIndex.value == index,
                          onTap: () {
                            subCategoryCtrl.select(index);
                            productCtrl.fetchProductsBySubCategory(
                              subCategoryId: sub['id'].toString(),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
            }),

            /// ==========================
            /// 🔹 PRODUCTS GRID
            /// ==========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Popular Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            Obx(() {
              if (productCtrl.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (productCtrl.products.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: Text('No products found')),
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
                  itemBuilder: (_, index) {
                    return ProductCard(product: productCtrl.products[index]);
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

/// =======================================================
/// 🔹 REUSABLE SECTION CARD (KEY TO CLEAN UI)
/// =======================================================
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              /// ✅ CLICKABLE ACTION TEXT
              if (actionText.isNotEmpty)
                GestureDetector(
                  onTap: onActionTap,
                  child: Text(
                    actionText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: onActionTap != null
                          ? Colors.blueAccent
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
