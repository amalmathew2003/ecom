import 'package:ecom/core/routes/app_routes.dart';
import 'package:ecom/features/user/cart/controller/card_controller.dart';
import 'package:ecom/features/user/home/controller/review_controller.dart';
import 'package:ecom/features/user/home/ui/product_details/widget/full_screen_image_viewer.dart';
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      reviewCtrl.fetchReviews(widget.product.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.product.imageUrl;

    return Scaffold(
      backgroundColor: ColorConst.bg,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [_imageHeader(images), _productInfo()],
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  // ================= IMAGE HEADER =================
  Widget _imageHeader(List<String> images) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .50,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(60),
              ),
              child: images.isNotEmpty
                  ? PageView.builder(
                      itemCount: images.length,
                      onPageChanged: (i) => setState(() => currentIndex = i),
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => Get.to(
                          () => FullScreenImageViewer(
                            images: images,
                            initialIndex: i,
                          ),
                        ),
                        child: Image.network(images[i], fit: BoxFit.cover),
                      ),
                    )
                  : _imageFallback(),
            ),

            /// BACK BUTTON (UNCHANGED STYLE)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              child: Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: ColorConst.textLight,
                    size: 20,
                  ),
                  onPressed: Get.back,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= PRODUCT INFO =================
  Widget _productInfo() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            Text(
              widget.product.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorConst.textLight,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "₹ ${widget.product.price}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: ColorConst.accent,
                  ),
                ),
                _ratingView(),
              ],
            ),

            const SizedBox(height: 8),
            _stockStatus(widget.product.stock),

            const SizedBox(height: 24),
            Divider(color: ColorConst.textMuted.withValues(alpha: .3)),

            const SizedBox(height: 16),
            const Text(
              "Product Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorConst.textLight,
              ),
            ),

            const SizedBox(height: 10),
            Text(
              widget.product.description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: ColorConst.textMuted,
              ),
            ),

            const SizedBox(height: 24),

            /// REVIEWS
            _reviewSection(),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // ================= REVIEW SECTION =================
  Widget _reviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Customer Reviews",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ColorConst.textLight,
          ),
        ),
        const SizedBox(height: 12),

        Obx(() {
          if (reviewCtrl.isLoading.value) {
            return const CircularProgressIndicator();
          }

          if (reviewCtrl.reviews.isEmpty) {
            return const Text(
              "No reviews yet",
              style: TextStyle(color: ColorConst.textMuted),
            );
          }

          return Column(
            children: reviewCtrl.reviews.map((review) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewCtrl.maskEmail(
                        review['reviewer_email']?.toString() ??
                            'Verified Buyer',
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColorConst.textMuted,
                      ),
                    ),

                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        review['rating'] as int,
                        (_) => const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      review['comment'] ?? '',
                      style: const TextStyle(
                        color: ColorConst.textLight,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }),

        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _showReviewDialog,
          icon: const Icon(Icons.rate_review_outlined, size: 18),
          label: const Text(
            "Write a Review",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: ColorConst.accent,
            side: BorderSide(
              color: ColorConst.accent.withValues(alpha: .6),
              width: 1.6,
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  // ================= REVIEW DIALOG =================
  void _showReviewDialog() {
    final commentCtrl = TextEditingController();
    int rating = 5;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: ColorConst.bg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE
                    const Text(
                      "Rate this product",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColorConst.textLight,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// STAR RATING
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final isSelected = i < rating;
                        return GestureDetector(
                          onTap: () => setState(() => rating = i + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              isSelected
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              size: 34,
                              color: isSelected ? Colors.amber : Colors.grey,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    /// COMMENT FIELD
                    TextField(
                      controller: commentCtrl,
                      maxLines: 3,
                      style: const TextStyle(color: ColorConst.textLight),
                      decoration: InputDecoration(
                        hintText: "Share your experience",
                        hintStyle: const TextStyle(color: ColorConst.textMuted),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: .15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ACTION BUTTONS
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: Get.back,
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: ColorConst.textMuted),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorConst.accent,
                              foregroundColor: ColorConst.textDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () async {
                              await reviewCtrl.submitReview(
                                productId: widget.product.id,
                                rating: rating,
                                comment: commentCtrl.text,
                              );
                              await reviewCtrl.fetchReviews(widget.product.id);
                              Get.back();
                            },
                            child: const Text(
                              "Submit",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= BOTTOM BAR =================
  Widget _bottomBar() => Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
    decoration: BoxDecoration(
      color: ColorConst.bg,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .25),
          blurRadius: 12,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final alreadyInCart = cartCtrl.isInCart(widget.product.id);

              return OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorConst.accent,
                  side: BorderSide(
                    color: ColorConst.accent.withValues(alpha: .6),
                    width: 1.4,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: widget.product.stock <= 0
                    ? null
                    : () async {
                        if (alreadyInCart) {
                          // 👉 GO TO CART
                          Get.toNamed(AppRoutes.usercart);
                          // or Get.to(() => CartScreen())
                        } else {
                          // 👉 ADD TO CART
                          await cartCtrl.addToCart(
                            productId: widget.product.id,
                            stock: widget.product.stock,
                          );
                          Get.snackbar(
                            "Added to Cart",
                            "${widget.product.name} added successfully",
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      },
                child: Text(
                  alreadyInCart ? "Go to Cart" : "Add to Cart",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(width: 14),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConst.accent,
                foregroundColor: ColorConst.textDark,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "Buy Now",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // ================= HELPERS =================
  Widget _ratingView() => Row(
    children: [
      const Icon(Icons.star, color: Colors.amber, size: 18),
      const SizedBox(width: 4),
      Text(widget.product.rating.toStringAsFixed(1)),
      const SizedBox(width: 6),
      Text("(${widget.product.ratingCount})"),
    ],
  );

  Widget _stockStatus(int stock) => Text(
    stock <= 0
        ? "Out of Stock"
        : stock <= 5
        ? "Only few left!"
        : "In Stock ($stock)",
    style: TextStyle(
      color: stock <= 0
          ? Colors.redAccent
          : stock <= 5
          ? Colors.orange
          : Colors.green,
    ),
  );

  Widget _imageFallback() => Container(
    color: Colors.grey.shade300,
    child: const Center(child: Icon(Icons.image_not_supported, size: 40)),
  );
}
