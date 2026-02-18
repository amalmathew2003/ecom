import 'package:ecom/features/admin/orders/controller/admin_order_controller.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:ecom/core/utils/responsive_layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StaffOrderScreen extends StatelessWidget {
  StaffOrderScreen({super.key});

  final controller = Get.put(AdminOrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.background,
      body: ResponsiveLayout(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.orders.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: NeoColors.accent),
                  );
                }
                if (controller.orders.isEmpty) {
                  return _buildEmptyState();
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchAllOrders,
                  color: NeoColors.accent,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      if (width > 900) {
                        return _buildWebGrid();
                      }
                      return _buildMobileList();
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

  Widget _buildHeader() {
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
            "FULFILLMENT",
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
            Icons.shopping_bag_outlined,
            size: 80,
            color: NeoColors.textLow.withOpacity(0.2),
          ),
          const SizedBox(height: 20),
          Text(
            "NO SHIPMENTS PENDING",
            style: GoogleFonts.oswald(
              color: NeoColors.textHigh,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: controller.orders.length,
      itemBuilder: (context, index) =>
          _orderCard(context, controller.orders[index])
              .animate()
              .fadeIn(delay: Duration(milliseconds: index * 50))
              .slideY(begin: 0.1),
    );
  }

  Widget _buildWebGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: controller.orders.length,
      itemBuilder: (context, index) => _orderCard(
        context,
        controller.orders[index],
      ).animate().fadeIn(delay: Duration(milliseconds: index * 30)).scale(),
    );
  }

  Widget _orderCard(BuildContext context, order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: NeoColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${order.id.substring(0, 8).toUpperCase()}',
                          style: GoogleFonts.oswald(
                            color: NeoColors.textHigh,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'MMM dd, hh:mm a',
                          ).format(order.createdAt).toUpperCase(),
                          style: GoogleFonts.montserrat(
                            color: NeoColors.textLow,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    _statusChip(order.status),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: NeoColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 16,
                        color: NeoColors.accent,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.userName?.toUpperCase() ?? 'CUSTOMER',
                            style: GoogleFonts.oswald(
                              color: NeoColors.textHigh,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),
                          if (order.userEmail != null)
                            Text(
                              order.userEmail!.toLowerCase(),
                              style: GoogleFonts.montserrat(
                                color: NeoColors.textLow,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: Colors.white10),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ORDER TOTAL",
                      style: GoogleFonts.oswald(
                        color: NeoColors.textLow,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      "₹${order.amount}",
                      style: GoogleFonts.oswald(
                        color: NeoColors.accent,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  order.id,
                  'PENDING',
                  Colors.orangeAccent,
                  Icons.access_time_filled_rounded,
                ),
                _actionButton(
                  order.id,
                  'PROCESSING',
                  Colors.blueAccent,
                  Icons.sync_rounded,
                ),
                _actionButton(
                  order.id,
                  'SUCCESS',
                  Colors.greenAccent,
                  Icons.check_circle_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String id, String status, Color color, IconData icon) {
    return InkWell(
      onTap: () => controller.updateOrderStatus(id, status),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              status.toUpperCase(),
              style: GoogleFonts.oswald(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        color = Colors.greenAccent;
        break;
      case 'PROCESSING':
        color = Colors.blueAccent;
        break;
      case 'CANCELLED':
        color = NeoColors.error;
        break;
      default:
        color = Colors.orangeAccent;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.oswald(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
