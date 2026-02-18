import 'package:flutter_animate/flutter_animate.dart';
import 'package:ecom/features/user/orders/controller/order_controller.dart';
import 'package:ecom/features/user/orders/ui/order_details_screen.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:ecom/core/utils/responsive_layout.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    final orderCtrl = Get.find<OrderController>();
    orderCtrl.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final orderCtrl = Get.find<OrderController>();

    return Scaffold(
      backgroundColor: NeoColors.background,
      body: ResponsiveLayout(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Obx(() {
                if (orderCtrl.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: NeoColors.accent),
                  );
                }
                if (orderCtrl.orders.isEmpty) return _buildEmptyState();

                return RefreshIndicator(
                  color: NeoColors.accent,
                  onRefresh: orderCtrl.fetchOrders,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      int crossAxisCount = 1;
                      if (width > 900) crossAxisCount = 2;

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: crossAxisCount == 1 ? 2.5 : 2.0,
                          crossAxisSpacing: 30,
                          mainAxisSpacing: 30,
                        ),
                        itemCount: orderCtrl.orders.length,
                        itemBuilder: (_, index) {
                          return _buildOrderCard(
                                orderCtrl.orders[index],
                                orderCtrl,
                              )
                              .animate(
                                delay: Duration(milliseconds: index * 50),
                              )
                              .fadeIn()
                              .slideY(begin: 0.1);
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: NeoColors.textHigh,
            ),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 15),
          Text(
            "ORDER HISTORY",
            style: GoogleFonts.oswald(
              color: NeoColors.textHigh,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: NeoColors.textLow.withOpacity(0.2),
          ),
          const SizedBox(height: 20),
          Text(
            "NO ORDERS YET",
            style: GoogleFonts.oswald(
              color: NeoColors.textHigh,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "YOUR TRANSACTION HISTORY WILL APPEAR HERE",
            style: GoogleFonts.montserrat(
              color: NeoColors.textLow,
              fontSize: 12,
            ),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildOrderCard(order, orderCtrl) {
    return Container(
      decoration: BoxDecoration(
        color: NeoColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () async {
            final result = await Get.to(() => OrderDetailsScreen(order: order));
            if (result == "cancel")
              orderCtrl.cancelOrder(order.id);
            else if (result == "confirm")
              orderCtrl.confirmDelivery(order.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ID: #${order.id.toString().substring(0, 8).toUpperCase()}",
                          style: GoogleFonts.oswald(
                            color: NeoColors.textLow,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(order.createdAt),
                          style: GoogleFonts.montserrat(
                            color: NeoColors.textHigh,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    _StatusChip(status: order.status),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: Colors.white10),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TOTAL AMOUNT",
                          style: GoogleFonts.oswald(
                            color: NeoColors.textLow,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${order.amount.toStringAsFixed(0)}",
                          style: GoogleFonts.oswald(
                            color: NeoColors.accent,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NeoColors.background,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: NeoColors.textHigh,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return "${date.day} ${months[date.month - 1]}, ${date.year}";
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        color = Colors.greenAccent;
        icon = Icons.check_circle_rounded;
        break;
      case 'PENDING':
        color = Colors.orangeAccent;
        icon = Icons.access_time_filled_rounded;
        break;
      case 'OUT_FOR_DELIVERY':
        color = Colors.blueAccent;
        icon = Icons.local_shipping_rounded;
        break;
      case 'DELIVERED':
        color = Colors.purpleAccent;
        icon = Icons.mark_email_read_rounded;
        break;
      case 'CANCELLED':
        color = Colors.redAccent;
        icon = Icons.cancel_rounded;
        break;
      default:
        color = Colors.blueAccent;
        icon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.oswald(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
