import 'package:ecom/features/admin/products/controller/product_controller.dart';
import 'package:ecom/features/user/home/ui/product_details/product_details_screen.dart';
import 'package:ecom/features/user/wishlist/controller/wishlist_controller.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistCtrl = Get.find<WishlistController>();
    final productCtrl = Get.find<AdminProductController>();

    return Scaffold(
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Wishlist",
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
          Obx(() {
            if (wishlistCtrl.wishlistItems.isNotEmpty) {
              return IconButton(
                onPressed: () => _confirmClearWishlist(wishlistCtrl),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (wishlistCtrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: ColorConst.primary),
          );
        }

        if (wishlistCtrl.wishlistItems.isEmpty) {
          return _buildEmptyState();
        }

        // Get products that are in wishlist
        final wishlistProducts = productCtrl.products
            .where((p) => wishlistCtrl.wishlistItems.contains(p.id))
            .toList();

        if (wishlistProducts.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: wishlistCtrl.fetchWishlist,
          color: ColorConst.primary,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: wishlistProducts.length,
            itemBuilder: (context, index) {
              final product = wishlistProducts[index];
              return _buildWishlistCard(product, wishlistCtrl);
            },
          ),
        );
      }),
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
            color: ColorConst.textMuted.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          const Text(
            "Your wishlist is empty",
            style: TextStyle(
              color: ColorConst.textLight,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap ❤️ on products to add them here",
            style: TextStyle(color: ColorConst.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistCard(product, WishlistController wishlistCtrl) {
    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailsScreen(product: product)),
      child: Container(
        decoration: BoxDecoration(
          color: ColorConst.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ColorConst.surface),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      product.imageUrl.isNotEmpty ? product.imageUrl.first : '',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: ColorConst.surface,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: ColorConst.textMuted,
                        ),
                      ),
                    ),
                  ),
                  // Remove Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => wishlistCtrl.toggleWishlist(product.id),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ColorConst.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹${product.price.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: ColorConst.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearWishlist(WishlistController ctrl) {
    Get.defaultDialog(
      title: "Clear Wishlist",
      middleText:
          "Are you sure you want to remove all items from your wishlist?",
      textConfirm: "Clear All",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        ctrl.clearWishlist();
        Get.back();
      },
    );
  }
}
