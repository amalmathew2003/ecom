import 'package:ecom/features/user/checkout/controller/checkout_controller.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final checkoutCrl = Get.find<CheckoutController>();

    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PAYMENT METHOD",
            style: GoogleFonts.oswald(
              color: NeoColors.textHigh,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ).animate().fadeIn().slideX(begin: -0.2),
          const SizedBox(height: 16),
          _option(
            title: "CASH ON DELIVERY",
            subtitle: "PAY WHEN THE ITEM REACHES YOUR DOORSTEP",
            selected: checkoutCrl.isCod,
            onTap: () => checkoutCrl.selectPaymentMethod(PaymentMethod.cod),
            index: 0,
          ),
          const SizedBox(height: 14),
          _option(
            title: "SECURE ONLINE",
            subtitle: "CARD / UPI / NETBANKING (SECURED BY RAZORPAY)",
            selected: checkoutCrl.isOnline,
            onTap: () => checkoutCrl.selectPaymentMethod(PaymentMethod.online),
            index: 1,
          ),
        ],
      );
    });
  }

  Widget _option({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
    required int index,
  }) {
    return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: selected
                  ? NeoColors.accent.withOpacity(0.05)
                  : NeoColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected
                    ? NeoColors.accent
                    : Colors.white.withOpacity(0.05),
                width: 2,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: NeoColors.accent.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? NeoColors.accent : NeoColors.textLow,
                      width: 2,
                    ),
                  ),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? NeoColors.accent : Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.oswald(
                          color: selected
                              ? NeoColors.accent
                              : NeoColors.textHigh,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.montserrat(
                          color: NeoColors.textLow,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: NeoColors.accent,
                    size: 24,
                  ).animate().scale(),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn()
        .slideY(begin: 0.1);
  }
}
