import 'package:ecom/features/user/home/controller/product_controller.dart';
import 'package:ecom/shared/widgets/neo_product_card.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class NeoSearchScreen extends StatelessWidget {
  NeoSearchScreen({super.key});

  final controller = Get.find<ProductController>();
  final searchCtrl = TextEditingController();

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
            child: _FloatingOrb(NeoColors.accent.withOpacity(0.1), 300),
          ),

          // 3. Content
          SafeArea(
            child: Column(
              children: [
                _buildSearchHeader(),
                Expanded(
                  child: Obx(() {
                    if (controller.isSearching.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: NeoColors.accent,
                        ),
                      );
                    }

                    if (controller.products.isEmpty &&
                        searchCtrl.text.isNotEmpty) {
                      return _buildEmptyState();
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                      itemCount: controller.products.length,
                      itemBuilder: (context, index) {
                        return NeoProductCard(
                              product: controller.products[index],
                            )
                            .animate()
                            .fadeIn(delay: (index * 50).ms)
                            .slideY(begin: 0.1);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back, color: NeoColors.textHigh),
              ),
              const SizedBox(width: 10),
              Text(
                "SEARCH //",
                style: GoogleFonts.oswald(
                  color: NeoColors.textHigh,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ).animate().blur(
                duration: const Duration(milliseconds: 800),
                begin: const Offset(5, 0),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(0), // Brutalist
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: TextField(
                  controller: searchCtrl,
                  autofocus: true,
                  style: GoogleFonts.oswald(
                    color: NeoColors.textHigh,
                    letterSpacing: 1,
                  ),
                  onChanged: (val) => controller.searchProducts(val),
                  decoration: InputDecoration(
                    hintText: "ENTER PRODUCT CODE OR NAME...",
                    hintStyle: GoogleFonts.oswald(
                      color: NeoColors.textLow,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                    border: InputBorder.none,
                    icon: const Icon(Icons.search, color: NeoColors.accent),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn().slideY(begin: -0.1),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: NeoColors.textLow.withOpacity(0.2),
          ),
          const SizedBox(height: 20),
          Text(
            "NO MATCH FOUND",
            style: GoogleFonts.oswald(
              color: NeoColors.textHigh,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "REFINE YOUR SEARCH PARAMETERS",
            style: GoogleFonts.oswald(
              color: NeoColors.textLow,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ).animate().fadeIn(),
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
