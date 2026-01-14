import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecom/features/user/home/controller/product_controller.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductCarousel extends StatelessWidget {
  ProductCarousel({super.key});

  final ProductController productCtrl = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (productCtrl.newArrivals.isEmpty) {
        return SizedBox(
          height: 220,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Stack(
                children: [
                  /// BACKGROUND GLOW
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.15),
                      ),
                    ),
                  ),

                  /// CONTENT
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'COMING SOON',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'New Arrivals Drop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Fresh styles • Better prices • Limited stock',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 16),

                      /// CTA BUTTON
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'Notify Me',
                          style: TextStyle(
                            color: Color(0xFF2575FC),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return CarouselSlider(
        options: CarouselOptions(
          height: 220,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.8,
        ),
        items: productCtrl.newArrivals.map((product) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    product.imageUrl.first,
                    fit: BoxFit.cover,
                  ),
                ),

                /// GRADIENT
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: .65),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                /// INFO
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: ColorConst.textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${product.price}',
                        style: const TextStyle(
                          color: ColorConst.price,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                /// BADGE
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ColorConst.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }
}
