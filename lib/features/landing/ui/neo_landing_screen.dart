import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:ecom/core/routes/app_routes.dart';
import 'package:ecom/core/utils/responsive_layout.dart';
import 'dart:ui';

class NeoLandingScreen extends StatelessWidget {
  const NeoLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.background,
      body: Stack(
        children: [
          // 1. Kinetic Grid Background
          Positioned.fill(child: CustomPaint(painter: GridPainter())),

          // 2. Cyber Ambient Glows
          Positioned(
            top: -150,
            right: -100,
            child: _floatingOrb(NeoColors.accent.withOpacity(0.15), 500),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: _floatingOrb(Colors.purpleAccent.withOpacity(0.1), 400),
          ),

          // 3. Main Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: ResponsiveLayout(
                    child: Center(
                      child: SingleChildScrollView(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return ResponsiveLayout.isMobile(context)
                                ? _buildMobileContent(context)
                                : _buildWebContent(context);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingOrb(Color color, double size) {
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
          duration: const Duration(seconds: 5),
        );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 60,
        vertical: 30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Logo
          Text(
            "NEO.MARKET",
            style: GoogleFonts.oswald(
              color: NeoColors.textHigh,
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: 4,
            ),
          ).animate().blur(duration: 800.ms, begin: const Offset(5, 0)),

          // Nav / CTA
          if (!isMobile)
            Row(
              children: [
                _menuItem("COLLECTIONS"),
                const SizedBox(width: 40),
                _menuItem("STUDIO"),
                const SizedBox(width: 40),
                _menuItem("LOGIN", onTap: () => Get.toNamed(AppRoutes.login)),
              ],
            )
          else
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu, color: NeoColors.textHigh),
            ),
        ],
      ),
    );
  }

  Widget _menuItem(String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: GoogleFonts.oswald(
          color: NeoColors.textMedium,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 300, child: _hero3DElement()),
          const SizedBox(height: 20),
          _buildHeroText(context, isMobile: true),
          const SizedBox(height: 40),
          _exploreButton(),
        ],
      ),
    );
  }

  Widget _buildWebContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeroText(context, isMobile: false),
                const SizedBox(height: 40),
                Text(
                  "Experience the next evolution of digital commerce.\nKinetic design meets brutalist aesthetics.",
                  style: GoogleFonts.montserrat(
                    color: NeoColors.textLow,
                    fontSize: 16,
                    height: 1.6,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.05),
                const SizedBox(height: 60),
                _exploreButton(),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: SizedBox(height: 600, child: _hero3DElement()),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroText(BuildContext context, {required bool isMobile}) {
    double fontSize = isMobile ? 60 : 120;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _glitchText("NEXT GEN", fontSize, 0),
        _glitchText("SHOPPING", fontSize, 200, color: NeoColors.accent),
        if (!isMobile) ...[
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 10,
            color: NeoColors.textHigh,
          ).animate().scaleX(delay: 800.ms, alignment: Alignment.centerLeft),
        ],
      ],
    );
  }

  Widget _glitchText(String text, double size, int delay, {Color? color}) {
    return Text(
          text,
          style: GoogleFonts.oswald(
            color: color ?? NeoColors.textHigh,
            fontSize: size,
            fontWeight: FontWeight.w900,
            height: 0.9,
            letterSpacing: -2,
          ),
        )
        .animate(delay: delay.ms)
        .fadeIn(duration: 500.ms)
        .moveY(begin: 20, end: 0)
        .blur(begin: const Offset(0, 5), end: Offset.zero);
  }

  Widget _exploreButton() {
    return InkWell(
      onTap: () => Get.offNamed(AppRoutes.usernav),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
        decoration: BoxDecoration(
          color: NeoColors.accent,
          boxShadow: [
            BoxShadow(
              color: NeoColors.accent.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "START SHOPPING",
              style: GoogleFonts.oswald(
                color: Colors.black, // Dark text on bright accent
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 15),
            const Icon(
              Icons.arrow_forward_sharp,
              color: Colors.black,
              size: 24,
            ),
          ],
        ),
      ),
    ).animate(delay: 1000.ms).fadeIn().scale();
  }

  Widget _hero3DElement() {
    return Stack(
          alignment: Alignment.center,
          children: [
            // Glow behind
            Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: NeoColors.accent.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: NeoColors.accent.withOpacity(0.2),
                        blurRadius: 100,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: const Duration(seconds: 3),
                ),

            // Stylized Icon/Image instead of 3D Model
            Icon(
              Icons.shopping_bag_outlined,
              size: 150,
              color: NeoColors.accent.withOpacity(0.8),
            ).animate().shimmer(duration: 2000.ms).fadeIn(),
          ],
        )
        .animate(delay: 200.ms)
        .fadeIn(duration: const Duration(seconds: 1))
        .scale();
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    const spacing = 50.0;

    // Vertical lines
    for (var i = 0.0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Horizontal lines
    for (var i = 0.0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
