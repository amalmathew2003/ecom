import 'package:ecom/features/admin/orders/controller/admin_order_controller.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:ecom/core/utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminOrderScreen extends StatelessWidget {
  AdminOrderScreen({super.key});

  final controller = Get.put(AdminOrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.background,
      body: ResponsiveLayout(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatusFilters(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.orders.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: NeoColors.accent),
                  );
                }

                if (controller.filteredOrders.isEmpty) {
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
            "ORDER MANAGEMENT",
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

  Widget _buildStatusFilters() {
    return Obx(() {
      return Container(
        height: 60,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            _filterChip("ALL ORDERS", "ALL"),
            _filterChip("PENDING", "PENDING"),
            _filterChip("SUCCESS", "SUCCESS"),
            _filterChip("CANCELLED", "CANCELLED"),
          ],
        ),
      );
    });
  }

  Widget _filterChip(String label, String filterValue) {
    final isSelected = controller.selectedFilter.value == filterValue;
    return GestureDetector(
      onTap: () => controller.applyFilter(filterValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? NeoColors.accent : NeoColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? NeoColors.accent
                : Colors.white.withOpacity(0.05),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: NeoColors.accent.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.oswald(
              color: isSelected ? Colors.white : NeoColors.textLow,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
        ),
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
            controller.selectedFilter.value == 'ALL'
                ? "NO ORDERS FOUND"
                : "NO ${controller.selectedFilter.value} ORDERS",
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
      itemCount: controller.filteredOrders.length,
      itemBuilder: (context, index) {
        return _orderCard(context, controller.filteredOrders[index])
            .animate()
            .fadeIn(delay: Duration(milliseconds: index * 50))
            .slideY(begin: 0.1);
      },
    );
  }

  Widget _buildWebGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 600,
        mainAxisExtent: 420, // Increased to prevent overflow
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: controller.filteredOrders.length,
      itemBuilder: (context, index) {
        return _orderCard(
          context,
          controller.filteredOrders[index],
        ).animate().fadeIn(delay: Duration(milliseconds: index * 30)).scale();
      },
    );
  }

  Widget _orderCard(BuildContext context, order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: NeoColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()}',
                            style: GoogleFonts.oswald(
                              color: NeoColors.textHigh,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 1,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                    ),
                    const SizedBox(width: 10),
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
                            order.userName?.toUpperCase() ?? 'ANONYMOUS USER',
                            style: GoogleFonts.oswald(
                              color: NeoColors.textHigh,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (order.userEmail != null)
                            Text(
                              order.userEmail!.toLowerCase(),
                              style: GoogleFonts.montserrat(
                                color: NeoColors.textLow,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                    Expanded(
                      child: Column(
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
                          Text(
                            "₹${order.amount}",
                            style: GoogleFonts.oswald(
                              color: NeoColors.accent,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "PAYMENT",
                            style: GoogleFonts.oswald(
                              color: NeoColors.textLow,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                order.paymentMethod == 'RAZORPAY'
                                    ? Icons.account_balance_wallet_rounded
                                    : Icons.payments_rounded,
                                size: 12,
                                color: NeoColors.textMedium,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                order.paymentMethod.toUpperCase(),
                                style: GoogleFonts.oswald(
                                  color: NeoColors.textHigh,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (order.paymentId != null)
                            Text(
                              order.paymentId!,
                              style: GoogleFonts.montserrat(
                                color: NeoColors.accent.withOpacity(0.7),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (order.managerName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              size: 12,
                              color: Colors.greenAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "VERIFIED",
                              style: GoogleFonts.oswald(
                                color: Colors.greenAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDeliveryInfo(order),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        color = Colors.greenAccent;
        break;
      case 'CANCELLED':
        color = NeoColors.error;
        break;
      default:
        color = Colors.orangeAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.oswald(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo(order) {
    final status = order.status.toUpperCase();
    String label;
    IconData icon;
    Color color;

    if (status == 'SUCCESS') {
      label = "DELIVERED";
      icon = Icons.check_circle_rounded;
      color = Colors.greenAccent;
    } else if (status == 'CANCELLED') {
      label = "CANCELLED";
      icon = Icons.cancel_rounded;
      color = NeoColors.error;
    } else {
      // Default to "Out for Delivery" for Pending status as requested
      label = "OUT FOR DELIVERY";
      icon = Icons.local_shipping_rounded;
      color = Colors.blueAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.oswald(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
