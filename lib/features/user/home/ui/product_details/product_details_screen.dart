import 'package:ecom/core/routes/app_routes.dart';
import 'package:ecom/features/user/cart/controller/card_controller.dart';
import 'package:ecom/features/user/checkout/ui/checkout_screen.dart';
import 'package:ecom/features/user/home/controller/product_controller.dart';
import 'package:ecom/features/user/home/controller/review_controller.dart';
import 'package:ecom/shared/widgets/neo_product_card.dart';
import 'package:ecom/features/user/home/ui/product_details/widget/full_screen_image_viewer.dart';
import 'package:ecom/features/user/nav/controller/nav_controller.dart';
import 'package:ecom/features/user/checkout/controller/checkout_controller.dart';
import 'package:ecom/shared/models/product_model.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:ecom/features/user/wishlist/controller/wishlist_controller.dart';
import 'package:ecom/core/utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  void _checkAuthAndAction(VoidCallback action) {
    if (Supabase.instance.client.auth.currentUser == null) {
      Get.toNamed(AppRoutes.login);
      Get.snackbar(
        'LOGIN REQUIRED',
        'PLEASE LOGIN TO CONTINUE YOUR PURCHASE',
        backgroundColor: NeoColors.surface,
        colorText: NeoColors.textHigh,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
        borderRadius: 20,
        icon: const Icon(Icons.lock_outline_rounded, color: NeoColors.accent),
      );
    } else {
      action();
    }
  }

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
    return Scaffold(
      backgroundColor: NeoColors.background,
      body: Stack(
        children: [
          // 1. Kinetic Background
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          // 2. Ambient Glow
          Positioned(
            top: -100,
            right: -100,
            child: _FloatingOrb(NeoColors.accent.withOpacity(0.1), 400),
          ),

          // 3. Main Content
          ResponsiveLayout(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (ResponsiveLayout.isMobile(context)) {
                  return _buildMobileLayout();
                }
                return _buildWebLayout();
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: ResponsiveLayout.isMobile(context)
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildMobileLayout() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(widget.product.imageUrl),
        _buildProductDetails(asSliver: true),
        _buildRelatedProducts(asSliver: true),
        _buildReviews(asSliver: true),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Widget _buildWebLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: Images
                Expanded(flex: 1, child: _buildWebImageGallery()),
                const SizedBox(width: 80),
                // Right side: Info
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainInfo(),
                      const SizedBox(height: 40),
                      _buildActions(isWeb: true),
                      const SizedBox(height: 60),
                      _buildDescription(),
                      const SizedBox(height: 60),
                      _webReviewSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
          _buildRelatedProducts(isWeb: true, asSliver: false),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildWebImageGallery() {
    final images = widget.product.imageUrl;
    return Column(
      children: [
        Container(
          height: 600,
          width: double.infinity,
          decoration: BoxDecoration(
            color: NeoColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(0), // Brutalist
            border: Border.all(color: NeoColors.accent.withOpacity(0.2)),
          ),
          child: Stack(
            children: [
              if (images.isNotEmpty)
                Hero(
                  tag: widget.product.id,
                  child: Image.network(
                    images[currentIndex],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
              else
                const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 100,
                    color: NeoColors.textLow,
                  ),
                ),
              Positioned(
                bottom: 30,
                right: 30,
                child: _glassButton(
                  "3D VIEW",
                  Icons.view_in_ar_rounded,
                  () => _show3DViewer(),
                ),
              ),
            ],
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => setState(() => currentIndex = index),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: currentIndex == index
                          ? NeoColors.accent
                          : Colors.transparent,
                      width: 1,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(images[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _glassButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.oswald(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child:
                  Text(
                    widget.product.name.toUpperCase(),
                    style: GoogleFonts.oswald(
                      color: NeoColors.textHigh,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      height: 0.9,
                    ),
                  ).animate().blur(
                    duration: const Duration(seconds: 1),
                    begin: const Offset(0, 5),
                  ),
            ),
            Obx(() {
              final wishlistCtrl = Get.find<WishlistController>();
              final isFav = wishlistCtrl.isInWishlist(widget.product.id);
              return IconButton(
                icon: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFav ? NeoColors.accent : NeoColors.textHigh,
                  size: 32,
                ),
                onPressed: () => wishlistCtrl.toggleWishlist(widget.product.id),
              );
            }),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: 60,
          height: 4,
          color: NeoColors.accent,
        ).animate().scaleX(
          alignment: Alignment.centerLeft,
          delay: const Duration(milliseconds: 300),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              "₹${widget.product.price}",
              style: GoogleFonts.oswald(
                color: NeoColors.accent,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 20),
            _buildStockBadge(),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(Icons.star_rounded, color: NeoColors.textHigh, size: 20),
            const SizedBox(width: 6),
            Text(
              widget.product.rating.toString(),
              style: GoogleFonts.oswald(
                color: NeoColors.textHigh,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "// ${widget.product.ratingCount} VERIFIED REVIEWS",
              style: GoogleFonts.oswald(
                color: NeoColors.textLow,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SPECIFICATIONS //",
          style: GoogleFonts.oswald(
            color: NeoColors.textLow,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.product.description,
          style: GoogleFonts.montserrat(
            color: NeoColors.textMedium,
            fontSize: 16,
            height: 1.8,
          ),
        ),
      ],
    );
  }

  Widget _buildActions({bool isWeb = false}) {
    return Obx(() {
      final inCart = cartCtrl.isInCart(widget.product.id);
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 60,
              child: OutlinedButton(
                onPressed: widget.product.stock <= 0
                    ? null
                    : () async {
                        _checkAuthAndAction(() async {
                          if (inCart) {
                            final nav = Get.find<UserNavController>();
                            nav.changeTab(1);
                            Get.until(
                              (route) =>
                                  route.settings.name == AppRoutes.usernav,
                            );
                          } else {
                            await cartCtrl.addToCart(
                              productId: widget.product.id,
                              stock: widget.product.stock,
                            );
                          }
                        });
                      },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: NeoColors.textHigh.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0), // Brutalist
                  ),
                ),
                child: Text(
                  inCart ? "IN CART" : "ADD TO CART",
                  style: GoogleFonts.oswald(
                    color: NeoColors.textHigh,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: widget.product.stock <= 0
                    ? null
                    : () {
                        _checkAuthAndAction(() {
                          final checkoutCtrl = Get.find<CheckoutController>();
                          checkoutCtrl.setBuyNow(
                            productId: widget.product.id,
                            amount: widget.product.price,
                          );
                          Get.to(() => const CheckoutScreen());
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: NeoColors.accent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: Text(
                  "BUY NOW",
                  style: GoogleFonts.oswald(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _webReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "COMMUNITY FEEDBACK",
              style: GoogleFonts.oswald(
                color: NeoColors.textHigh,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            _glassButton("WRITE REVIEW", Icons.edit, _showReviewDialog),
          ],
        ),
        const SizedBox(height: 30),
        Obx(() {
          if (reviewCtrl.reviews.isEmpty) {
            return const Text(
              "Awaiting data...",
              style: TextStyle(color: NeoColors.textMedium),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviewCtrl.reviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) =>
                _buildReviewCard(reviewCtrl.reviews[index]),
          );
        }),
      ],
    );
  }

  Widget _buildAppBar(List<String> images) {
    return SliverAppBar(
      expandedHeight: 500,
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.5),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
      ),
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
              ),
            Positioned(
              bottom: 30,
              right: 30,
              child: _glassButton(
                "3D VIEW",
                Icons.view_in_ar_rounded,
                () => _show3DViewer(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails({bool asSliver = false}) {
    Widget content = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainInfo(),
          const SizedBox(height: 40),
          _buildDescription(),
          const SizedBox(height: 32),
          Divider(color: Colors.white.withOpacity(0.1)),
        ],
      ),
    );
    return asSliver ? SliverToBoxAdapter(child: content) : content;
  }

  Widget _buildRelatedProducts({bool isWeb = false, bool asSliver = false}) {
    Widget content = Obx(() {
      if (relatedProducts.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 60 : 24,
              vertical: 20,
            ),
            child: Text(
              "RELATED //",
              style: GoogleFonts.oswald(
                color: NeoColors.textLow,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          SizedBox(
            height: 350,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: isWeb ? 60 : 16),
              scrollDirection: Axis.horizontal,
              itemCount: relatedProducts.length,
              itemBuilder: (context, index) => Container(
                width: 220,
                margin: const EdgeInsets.only(right: 30),
                child: NeoProductCard(product: relatedProducts[index]),
              ),
            ),
          ),
        ],
      );
    });
    return asSliver ? SliverToBoxAdapter(child: content) : content;
  }

  Widget _buildStockBadge() {
    final stock = widget.product.stock;
    final isOut = stock <= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isOut ? Colors.red : NeoColors.accent).withOpacity(0.1),
        border: Border.all(
          color: (isOut ? Colors.red : NeoColors.accent).withOpacity(0.5),
        ),
      ),
      child: Text(
        isOut ? "OUT OF STOCK" : "IN STOCK",
        style: GoogleFonts.oswald(
          color: isOut ? Colors.red : NeoColors.accent,
          fontSize: 10,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildReviews({bool asSliver = false}) {
    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: _webReviewSection(),
    );
    return asSliver ? SliverToBoxAdapter(child: content) : content;
  }

  Widget _buildReviewCard(dynamic review) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: NeoColors.textHigh,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  review['reviewer_email'][0].toUpperCase(),
                  style: GoogleFonts.oswald(
                    color: NeoColors.background,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  reviewCtrl.maskEmail(review['reviewer_email']),
                  style: GoogleFonts.oswald(
                    color: NeoColors.textHigh,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: i < review['rating']
                        ? NeoColors.accent
                        : Colors.white10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            review['comment'],
            style: GoogleFonts.montserrat(
              color: NeoColors.textMedium,
              height: 1.6,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 34),
      decoration: BoxDecoration(
        color: NeoColors.background.withOpacity(0.9),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: _buildActions(),
    );
  }

  void _showReviewDialog() {
    final commentCtrl = TextEditingController();
    int rating = 5;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: NeoColors.background,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          title: Text(
            "WRITE A REVIEW",
            style: GoogleFonts.oswald(
              color: NeoColors.textHigh,
              letterSpacing: 2,
            ),
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
                      size: 40,
                      color: i < rating ? NeoColors.accent : Colors.white10,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: commentCtrl,
                maxLines: 4,
                style: const TextStyle(color: NeoColors.textHigh),
                decoration: InputDecoration(
                  hintText: "Review content...",
                  hintStyle: const TextStyle(color: NeoColors.textLow),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                "CANCEL",
                style: TextStyle(color: NeoColors.textLow),
              ),
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
                backgroundColor: NeoColors.accent,
                foregroundColor: Colors.black,
                shape: const RoundedRectangleBorder(),
              ),
              child: const Text("SUBMIT"),
            ),
          ],
        ),
      ),
    );
  }

  void _show3DViewer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            const SizedBox(height: 25),
            Container(width: 40, height: 4, color: Colors.white24),
            const SizedBox(height: 25),
            Text(
              "3D EXPLORER",
              style: GoogleFonts.oswald(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                fontSize: 20,
              ),
            ),
            const Expanded(
              child: ModelViewer(
                src:
                    'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
                alt: "3D Product",
                ar: true,
                autoRotate: true,
                cameraControls: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 60),
                  shape: const RoundedRectangleBorder(),
                ),
                child: Text(
                  "CLOSE",
                  style: GoogleFonts.oswald(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    const spacing = 40.0;

    for (var i = 0.0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (var i = 0.0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FloatingOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _FloatingOrb(this.color, this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color, blurRadius: 100, spreadRadius: 20),
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.1, 1.1),
          duration: const Duration(seconds: 4),
        );
  }
}
