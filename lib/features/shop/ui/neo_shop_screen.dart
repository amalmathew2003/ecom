import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:ecom/features/user/home/controller/product_controller.dart';
import 'package:ecom/shared/widgets/neo_product_card.dart';
import 'package:ecom/core/utils/responsive_layout.dart';
import 'package:ecom/features/shop/ui/neo_search_screen.dart';
import 'package:ecom/features/user/nav/controller/nav_controller.dart';
import 'dart:ui';

class NeoShopScreen extends StatelessWidget {
  const NeoShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productCtrl = Get.find<ProductController>();

    return Scaffold(
      backgroundColor: NeoColors.background,
      body: Stack(
        children: [
          // 1. Kinetic Background
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          // 2. Ambient Orbs
          Positioned(
            top: -100,
            right: -100,
            child: _FloatingOrb(NeoColors.accent.withOpacity(0.15), 400),
          ),
          Positioned(
            bottom: 200,
            left: -50,
            child: _FloatingOrb(Colors.purpleAccent.withOpacity(0.1), 300),
          ),

          // 3. Content
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(context),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  _buildHeroSection(context),
                  _buildSectionHeader(context, "CATEGORIES"),
                  _buildCategoryList(context, productCtrl),
                  _buildSectionHeader(context, "NEW ARRIVALS"),
                  _buildProductGrid(context, productCtrl),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    return SliverAppBar(
      backgroundColor: Colors.transparent, // Glass effect handled by body
      surfaceTintColor: Colors.transparent,
      floating: true,
      elevation: 0,
      centerTitle: false,
      pinned: !isMobile,
      expandedHeight: isMobile ? null : 100,
      title: Padding(
        padding: EdgeInsets.only(left: isMobile ? 0 : 20),
        child:
            Text(
              "NEO.STORE",
              style: GoogleFonts.oswald(
                color: NeoColors.textHigh,
                fontWeight: FontWeight.w900,
                fontSize: isMobile ? 24 : 32,
                letterSpacing: 4,
              ),
            ).animate().blur(
              duration: const Duration(milliseconds: 800),
              begin: const Offset(5, 0),
            ),
      ),
      actions: [
        _iconButton(Icons.search, () => Get.to(() => NeoSearchScreen())),
        const SizedBox(width: 10),
        _iconButton(
          Icons.shopping_bag_outlined,
          () => Get.find<UserNavController>().changeTab(1),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: NeoColors.textHigh, size: 20),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 40,
          vertical: 20,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 40,
          horizontal: 20,
        ), // Added padding for content
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0), // Brutalist square
          border: Border.all(color: NeoColors.accent.withOpacity(0.5)),
          color: Colors.black.withOpacity(0.4),
        ),
        child: Stack(
          children: [
            // Decorative lines
            Positioned(
              top: 0,
              left: 0,
              child: Container(width: 40, height: 2, color: NeoColors.textHigh),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(width: 40, height: 2, color: NeoColors.textHigh),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "CYBER\nAESTHETICS",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.oswald(
                      color: Colors.white,
                      fontSize: isMobile ? 42 : 80,
                      fontWeight: FontWeight.w900,
                      height: 0.9,
                      letterSpacing: 2,
                    ),
                  ).animate().blur(
                    duration: const Duration(seconds: 1),
                    begin: const Offset(0, 10),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(color: NeoColors.textHigh),
                    child: Text(
                      "EXPLORE NOW",
                      style: GoogleFonts.oswald(
                        color: NeoColors.background,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ).animate().scale(delay: const Duration(milliseconds: 500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    ProductController controller,
  ) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final categories = [
      {'name': 'AUDIO', 'code': '01'},
      {'name': 'WEAR', 'code': '02'},
      {'name': 'TECH', 'code': '03'},
      {'name': 'GEAR', 'code': '04'},
    ];

    return SliverToBoxAdapter(
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 15),
          itemBuilder: (context, index) {
            final cat = categories[index];
            return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    color: Colors.white.withOpacity(0.02),
                  ),
                  child: Row(
                    children: [
                      Text(
                        cat['code']!,
                        style: GoogleFonts.oswald(
                          color: NeoColors.accent,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        cat['name']!,
                        style: GoogleFonts.oswald(
                          color: NeoColors.textHigh,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                )
                .animate(delay: Duration(milliseconds: index * 100))
                .fadeIn()
                .slideX();
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Row(
          children: [
            Expanded(
              child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                title.toUpperCase(),
                style: GoogleFonts.oswald(
                  color: NeoColors.textLow,
                  fontSize: 12,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, ProductController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(50),
            child: Center(
              child: CircularProgressIndicator(color: NeoColors.accent),
            ),
          ),
        );
      }

      final isMobile = ResponsiveLayout.isMobile(context);
      final width = MediaQuery.of(context).size.width;
      int crossAxisCount = isMobile ? 2 : (width > 1200 ? 5 : 4);

      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: isMobile ? 0.65 : 0.70,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final product = controller.products[index];
            return NeoProductCard(product: product)
                .animate(delay: Duration(milliseconds: index * 50))
                .fadeIn()
                .slideY(begin: 0.05);
          }, childCount: controller.products.length),
        ),
      );
    });
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
              BoxShadow(color: color, blurRadius: 80, spreadRadius: 20),
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
