import 'package:ecom/features/user/home/controller/product_controller.dart';
import 'package:ecom/features/user/wishlist/controller/wishlist_controller.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:ecom/core/utils/responsive_layout.dart';
import 'package:ecom/shared/widgets/neo_product_card.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistCtrl = Get.find<WishlistController>();
    final productCtrl = Get.find<ProductController>();

    return Scaffold(
      backgroundColor: NeoColors.background,
      body: ResponsiveLayout(
        child: Column(
          children: [
            _buildHeader(context, wishlistCtrl),
            Expanded(
              child: Obx(() {
                if (wishlistCtrl.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: NeoColors.accent),
                  );
                }

                final wishlistProducts = productCtrl.products
                    .where((p) => wishlistCtrl.wishlistItems.contains(p.id))
                    .toList();

                if (wishlistProducts.isEmpty) return _buildEmptyState();

                return RefreshIndicator(
                  onRefresh: () => wishlistCtrl.fetchWishlist(),
                  color: NeoColors.accent,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      int crossAxisCount = 2;
                      if (width > 1200)
                        crossAxisCount = 4;
                      else if (width > 800)
                        crossAxisCount = 3;

                      return GridView.builder(
                        padding: const EdgeInsets.all(24),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                        ),
                        itemCount: wishlistProducts.length,
                        itemBuilder: (context, index) {
                          return NeoProductCard(
                            product: wishlistProducts[index],
                          );
                        },
                      );
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

  Widget _buildHeader(BuildContext context, WishlistController wishlistCtrl) {
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
                "WISHLIST",
                style: GoogleFonts.oswald(
                  color: NeoColors.textHigh,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          Obx(
            () => wishlistCtrl.wishlistItems.isNotEmpty
                ? IconButton(
                    onPressed: () => _confirmClearWishlist(wishlistCtrl),
                    icon: const Icon(
                      Icons.delete_sweep_rounded,
                      color: NeoColors.error,
                      size: 28,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 80,
            color: NeoColors.textLow.withOpacity(0.2),
          ),
          const SizedBox(height: 20),
          Text(
            "YOUR WISHLIST IS EMPTY",
            style: GoogleFonts.oswald(
              color: NeoColors.textHigh,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "TAP ❤️ ON PRODUCTS TO SAVE THEM HERE",
            style: GoogleFonts.montserrat(
              color: NeoColors.textLow,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearWishlist(WishlistController ctrl) {
    Get.defaultDialog(
      backgroundColor: NeoColors.surface,
      title: "CLEAR WISHLIST",
      titleStyle: GoogleFonts.oswald(
        color: NeoColors.textHigh,
        letterSpacing: 1,
      ),
      middleText: "Are you sure you want to remove everything?",
      middleTextStyle: GoogleFonts.montserrat(color: NeoColors.textLow),
      textConfirm: "YES, CLEAR ALL",
      textCancel: "CANCEL",
      confirmTextColor: Colors.white,
      buttonColor: NeoColors.error,
      cancelTextColor: NeoColors.textLow,
      onConfirm: () {
        ctrl.clearWishlist();
        Get.back();
      },
    );
  }
}
