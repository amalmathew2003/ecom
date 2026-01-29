import 'package:ecom/core/routes/app_routes.dart';
import 'package:ecom/features/user/cart/controller/card_controller.dart';
import 'package:ecom/features/user/checkout/ui/checkout_screen.dart';
import 'package:ecom/features/user/home/controller/product_controller.dart';
import 'package:ecom/features/user/home/controller/review_controller.dart';
import 'package:ecom/features/user/home/ui/home/widget/product_card.dart';
import 'package:ecom/features/user/home/ui/product_details/widget/full_screen_image_viewer.dart';
import 'package:ecom/features/user/nav/controller/nav_controller.dart';
import 'package:ecom/features/user/checkout/controller/checkout_controller.dart';
import 'package:ecom/shared/models/product_model.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int currentIndex = 0;
  final reviewCtrl = Get.find<ReviewController>();
  final cartCtrl = Get.find<CartController>();
  final productCtrl = Get.find<ProductController>();
  final relatedProducts = <ProductModel>[].obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reviewCtrl.fetchReviews(widget.product.id);
      final related = await productCtrl.fetchRelatedProducts(
        widget.product.categoryId,
        widget.product.id,
      );
      relatedProducts.assignAll(related);
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.product.imageUrl;

    return Scaffold(
      backgroundColor: ColorConst.bg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(images),
          _buildProductDetails(),
          _buildRelatedProducts(),
          _buildReviews(),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar(List<String> images) {
    return SliverAppBar(
      expandedHeight: 450,
      backgroundColor: ColorConst.bg,
      leadingWidth: 80,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: ColorConst.bg.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: ColorConst.bg.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.share_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {},
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (images.isNotEmpty)
              PageView.builder(
                itemCount: images.length,
                onPageChanged: (i) => setState(() => currentIndex = i),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => Get.to(
                    () =>
                        FullScreenImageViewer(images: images, initialIndex: i),
                  ),
                  child: Hero(
                    tag: widget.product.id,
                    child: Image.network(images[i], fit: BoxFit.cover),
                  ),
                ),
              )
            else
              Container(
                color: ColorConst.surface,
                child: const Icon(Icons.image_not_supported, size: 40),
              ),

            /// INDICATOR
            if (images.length > 1)
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: images.asMap().entries.map((entry) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: currentIndex == entry.key ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: currentIndex == entry.key
                            ? ColorConst.primary
                            : Colors.white.withOpacity(0.5),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          color: ColorConst.textLight,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber[600],
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.product.rating.toString(),
                            style: const TextStyle(
                              color: ColorConst.textLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "(${widget.product.ratingCount} reviews)",
                            style: const TextStyle(color: ColorConst.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  "₹${widget.product.price}",
                  style: const TextStyle(
                    color: ColorConst.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Description",
              style: TextStyle(
                color: ColorConst.textLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.product.description,
              style: TextStyle(
                color: ColorConst.textMuted,
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            _buildStockBadge(),
            const SizedBox(height: 32),
            const Divider(color: ColorConst.surface),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedProducts() {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (relatedProducts.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                "You May Also Like",
                style: TextStyle(
                  color: ColorConst.textLight,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(
              height: 280,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: relatedProducts.length,
                itemBuilder: (context, index) {
                  final product = relatedProducts[index];
                  return Container(
                    width: 170,
                    margin: const EdgeInsets.only(right: 16),
                    child: ProductCard(product: product),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(color: ColorConst.surface),
            ),
            const SizedBox(height: 16),
          ],
        );
      }),
    );
  }

  Widget _buildStockBadge() {
    final stock = widget.product.stock;
    final isLow = stock > 0 && stock <= 5;
    final isOut = stock <= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            (isOut ? Colors.red : (isLow ? Colors.orange : ColorConst.primary))
                .withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isOut
            ? "Out of Stock"
            : (isLow ? "Only $stock items left!" : "In Stock"),
        style: TextStyle(
          color: isOut
              ? Colors.red
              : (isLow ? Colors.orange : ColorConst.primary),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildReviews() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Customer Reviews",
                  style: TextStyle(
                    color: ColorConst.textLight,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _showReviewDialog,
                  child: const Text(
                    "Write a review",
                    style: TextStyle(color: ColorConst.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (reviewCtrl.isLoading.value)
                return const Center(child: CircularProgressIndicator());
              if (reviewCtrl.reviews.isEmpty) {
                return const Text(
                  "No reviews for this product yet.",
                  style: TextStyle(color: ColorConst.textMuted),
                );
              }
              return Column(
                children: reviewCtrl.reviews
                    .map((r) => _buildReviewCard(r))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(dynamic review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConst.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorConst.surface.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: ColorConst.primary.withOpacity(0.2),
                child: Text(
                  (review['reviewer_email'] ?? "U")[0].toUpperCase(),
                  style: const TextStyle(
                    color: ColorConst.primary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reviewCtrl.maskEmail(review['reviewer_email'] ?? "User"),
                  style: const TextStyle(
                    color: ColorConst.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: i < (review['rating'] ?? 0)
                        ? Colors.amber
                        : ColorConst.textMuted.withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'] ?? "",
            style: const TextStyle(color: ColorConst.textMuted, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 34),
      decoration: BoxDecoration(
        color: ColorConst.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        children: [
          Obx(() {
            final inCart = cartCtrl.isInCart(widget.product.id);
            return Expanded(
              child: ElevatedButton(
                onPressed: widget.product.stock <= 0
                    ? null
                    : () async {
                        if (inCart) {
                          final nav = Get.find<UserNavController>();
                          nav.changeTab(1);
                          Get.until(
                            (route) => route.settings.name == AppRoutes.usernav,
                          );
                        } else {
                          await cartCtrl.addToCart(
                            productId: widget.product.id,
                            stock: widget.product.stock,
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: inCart
                      ? ColorConst.surface
                      : ColorConst.primary.withOpacity(0.15),
                  foregroundColor: inCart
                      ? ColorConst.textLight
                      : ColorConst.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  inCart ? "Go to Cart" : "Add to Cart",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: ColorConst.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: ColorConst.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: widget.product.stock <= 0
                    ? null
                    : () {
                        final checkoutCtrl = Get.find<CheckoutController>();
                        checkoutCtrl.setBuyNow(
                          productId: widget.product.id,
                          amount: widget.product.price,
                        );
                        Get.to(() => const CheckoutScreen());
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Buy Now",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog() {
    final commentCtrl = TextEditingController();
    int rating = 5;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: ColorConst.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            "Write a Review",
            style: TextStyle(color: ColorConst.textLight),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => GestureDetector(
                    onTap: () => setState(() => rating = i + 1),
                    child: Icon(
                      Icons.star_rounded,
                      size: 36,
                      color: i < rating
                          ? Colors.amber
                          : ColorConst.textMuted.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: commentCtrl,
                maxLines: 4,
                style: const TextStyle(color: ColorConst.textLight),
                decoration: InputDecoration(
                  hintText: "Your experience...",
                  hintStyle: const TextStyle(color: ColorConst.textMuted),
                  filled: true,
                  fillColor: ColorConst.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await reviewCtrl.submitReview(
                  productId: widget.product.id,
                  rating: rating,
                  comment: commentCtrl.text,
                );
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConst.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
