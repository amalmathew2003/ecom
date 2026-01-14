import 'package:ecom/features/user/orders/controller/oder_controller.dart';
import 'package:ecom/features/user/orders/ui/oder_details_screen.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderCtrl = Get.find<OrderController>();

    return Scaffold(
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: ColorConst.bg,
        elevation: 0,
        title: const Text(
          "My Orders",
          style: TextStyle(color: ColorConst.textLight),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: ColorConst.textLight),
      ),
      body: Obx(() {
        if (orderCtrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: ColorConst.accent),
          );
        }

        if (orderCtrl.orders.isEmpty) {
          return const Center(
            child: Text(
              "No orders yet",
              style: TextStyle(color: ColorConst.textMuted),
            ),
          );
        }

        return RefreshIndicator(
          color: ColorConst.accent,
          backgroundColor: ColorConst.card,
          onRefresh: orderCtrl.fetchOrders,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orderCtrl.orders.length,
            itemBuilder: (_, index) {
              final order = orderCtrl.orders[index];

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  final result = await Get.to(
                    () => OrderDetailsScreen(order: order),
                  );

                  if (result == 'cancel') {
                    await orderCtrl.cancelOrder(order.id);
                    Get.snackbar(
                      'Cancelled',
                      'Order cancelled successfully',
                      backgroundColor: ColorConst.card,
                      colorText: ColorConst.textLight,
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// LEFT INFO
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "₹${order.amount.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: ColorConst.accent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatDate(order.createdAt),
                            style: const TextStyle(
                              color: ColorConst.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            order.orderType.replaceAll('_', ' '),
                            style: const TextStyle(
                              color: ColorConst.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      /// RIGHT SIDE
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _StatusChip(status: order.status),
                          const SizedBox(height: 10),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: ColorConst.textMuted,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }
}

/// ================= STATUS CHIP =================
class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return Colors.greenAccent;
      case 'FAILED':
        return ColorConst.danger;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.orangeAccent;
    }
  }
}
