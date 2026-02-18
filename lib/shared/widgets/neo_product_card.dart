import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:ecom/shared/models/product_model.dart';
import 'package:get/get.dart';
import 'package:ecom/features/user/home/ui/product_details/product_details_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NeoProductCard extends StatefulWidget {
  final ProductModel product;
  const NeoProductCard({super.key, required this.product});

  @override
  State<NeoProductCard> createState() => _NeoProductCardState();
}

class _NeoProductCardState extends State<NeoProductCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () =>
            Get.to(() => ProductDetailsScreen(product: widget.product)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: NeoColors.surface,
                  borderRadius: BorderRadius.circular(isHovered ? 30 : 20),
                  boxShadow: isHovered
                      ? [
                          BoxShadow(
                            color: NeoColors.accent.withOpacity(0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ]
                      : [],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    AnimatedScale(
                      scale: isHovered ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                      child: Center(
                        child: widget.product.imageUrl.isNotEmpty
                            ? Image.network(
                                widget.product.imageUrl[0],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : const Icon(
                                Icons.image_not_supported,
                                color: NeoColors.textLow,
                              ),
                      ),
                    ),
                    Positioned(
                      top: 15,
                      right: 15,
                      child: AnimatedOpacity(
                        opacity: isHovered ? 1.0 : 0.5,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isHovered
                                ? NeoColors.accent
                                : Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite_border_rounded,
                            color: isHovered ? Colors.white : Colors.white70,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    if (isHovered)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                NeoColors.accent.withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "QUICK VIEW",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ).animate().fadeIn().slideY(begin: 1.0),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      color: isHovered ? NeoColors.accent : NeoColors.textHigh,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹${widget.product.price}",
                    style: GoogleFonts.oswald(
                      color: isHovered ? NeoColors.textHigh : NeoColors.accent,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
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
}
