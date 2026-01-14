import 'package:ecom/features/user/checkout/controller/checkout_controller.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final checkoutCrl = Get.find<CheckoutController>();

    return Obx(() {
      return Column(
        children: [
          _option(
            title: "Cash on Delivery",
            subtitle: "Pay when item arrives",
            selected: checkoutCrl.isCod,
            onTap: () =>
                checkoutCrl.selectPaymentMethod(PaymentMethod.cod),
          ),
          const SizedBox(height: 14),
          _option(
            title: "Online Payment",
            subtitle: "UPI / Card / Netbanking",
            selected: checkoutCrl.isOnline,
            onTap: () =>
                checkoutCrl.selectPaymentMethod(PaymentMethod.online),
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
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: ColorConst.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? ColorConst.accent : Colors.transparent,
            width: 1.6,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected
                  ? ColorConst.accent
                  : ColorConst.textMuted, 
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: ColorConst.textLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: ColorConst.textMuted,
                      fontSize: 12,
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
