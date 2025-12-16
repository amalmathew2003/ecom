import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecom/features/user/home/controller/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductCarousel extends StatelessWidget {
  ProductCarousel({super.key});

  final ProductController productCtrl = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // 🔹 Responsive values
    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1024;

    final double carouselHeight = isMobile
        ? 220
        : isTablet
        ? 220
        : 260;

    final double viewport = isMobile
        ? 0.8
        : isTablet
        ? 0.75
        : 0.6;

    return Obx(() {
      if (productCtrl.newArrivals.isEmpty) {
        return SizedBox(height: carouselHeight);
      }

      return CarouselSlider(
        options: CarouselOptions(
          height: carouselHeight,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: viewport,
          autoPlayInterval: const Duration(seconds: 4),
        ),
        items: productCtrl.newArrivals.map((product) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                /// IMAGE
                Positioned.fill(
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.broken_image)),
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
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                /// PRODUCT INFO
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${product.price}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 14 : 16,
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
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
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
