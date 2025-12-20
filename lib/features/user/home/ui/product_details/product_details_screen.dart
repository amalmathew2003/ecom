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
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.product.imageUrl;

    return Scaffold(
      backgroundColor: ColorConst.bg,

      /// ✅ ALWAYS SCROLLABLE
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          /// ================= IMAGE HEADER =================
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .50,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  /// IMAGE CAROUSEL
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(60),
                    ),
                    child: images.isNotEmpty
                        ? PageView.builder(
                            itemCount: images.length,
                            onPageChanged: (index) {
                              setState(() => _currentIndex = index);
                            },
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Get.to(
                                    () => FullScreenImageViewer(
                                      images: images,
                                      initialIndex: index,
                                    ),
                                    transition: Transition.fadeIn,
                                  );
                                },
                                child: Image.network(
                                  images[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) =>
                                      _imageFallback(),
                                ),
                              );
                            },
                          )
                        : _imageFallback(),
                  ),

                  /// ✅ GRADIENT OVERLAY (DOES NOT BLOCK TOUCH)
                  IgnorePointer(
                    ignoring: true, // 🔥 KEY FIX
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(60),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.55),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// BACK BUTTON
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 16,
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: ColorConst.textLight,
                          size: 20,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ),

                  /// DOT INDICATOR
                  if (images.length > 1)
                    Positioned(
                      bottom: 18,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentIndex == index ? 20 : 8,
                            decoration: BoxDecoration(
                              color: _currentIndex == index
                                  ? ColorConst.accent
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          /// ================= PRODUCT INFO =================
          SliverToBoxAdapter(
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
                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          SizedBox(width: 4),
                          Text(
                            "4.5",
                            style: TextStyle(color: ColorConst.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Divider(color: ColorConst.textMuted.withOpacity(0.3)),
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

                  /// EXTRA SPACE TO MAKE SCROLL OBVIOUS
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),

      /// ================= BOTTOM ACTION =================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: ColorConst.bg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
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
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorConst.accent,
                    side: BorderSide(color: ColorConst.accent.withOpacity(0.6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Add to Cart",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConst.accent,
                    foregroundColor: ColorConst.textDark,
                    elevation: 6,
                    shadowColor: Colors.black.withOpacity(0.35),
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
      ),
    );
  }

  /// ================= FALLBACK IMAGE =================
  Widget _imageFallback() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(child: Icon(Icons.image_not_supported, size: 40)),
    );
  }
}
