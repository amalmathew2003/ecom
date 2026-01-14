import 'package:ecom/features/user/orders/data/oder_model.dart';
import 'package:ecom/features/user/orders/ui/order_tracking_timeline.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: ColorConst.bg,
        elevation: 0,
        title: Text(
          "Order Details",
          style: TextStyle(color: ColorConst.textLight),
        ),
        iconTheme: IconThemeData(color: ColorConst.textLight),
      ),
    body:   Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ORDER SUMMARY
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row("Order Amount", "₹${order.amount.toStringAsFixed(0)}",
                      highlight: true),
                  _row("Status", order.status),
                  _row("Order Type", order.orderType),
                  _row(
                    "Date",
                    _formatDate(order.createdAt),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// TRACKING
            OrderTrackingTimeline(status: order.status),

            const Spacer(),

            /// CANCEL BUTTON (ONLY PENDING)
            if (order.status == "PENDING")
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Get.back(result: "cancel"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConst.danger,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Cancel Order",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ColorConst.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .35),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _row(String title, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: ColorConst.textMuted),
          ),
          Text(
            value,
            style: TextStyle(
              color: highlight ? ColorConst.accent : ColorConst.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }
}