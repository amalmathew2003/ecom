import 'package:ecom/features/admin/orders/controller/admin_order_controller.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Staff Order Screen - Staff can process orders but CANNOT cancel them
class StaffOrderScreen extends StatelessWidget {
  StaffOrderScreen({super.key});

  final controller = Get.put(AdminOrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Order Processing',
          style: TextStyle(
            color: ColorConst.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ColorConst.textLight,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.orders.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: ColorConst.primary),
          );
        }

        if (controller.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: ColorConst.textMuted.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No orders to process",
                  style: TextStyle(color: ColorConst.textMuted),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Status Filters
            _buildStatusFilters(),

            // Order List
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.fetchAllOrders,
                color: ColorConst.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.orders.length,
                  itemBuilder: (context, index) {
                    final order = controller.orders[index];
                    return _buildOrderCard(context, order);
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatusFilters() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip("All Orders", true),
          _filterChip("Pending", false),
          _filterChip("Processing", false),
          _filterChip("Ready", false),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? ColorConst.primary : ColorConst.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? ColorConst.primary : ColorConst.surface,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : ColorConst.textMuted,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ColorConst.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorConst.surface, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
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
                          style: const TextStyle(
                            color: ColorConst.textLight,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, hh:mm a').format(order.createdAt),
                          style: const TextStyle(
                            color: ColorConst.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    _statusChip(order.status),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: ColorConst.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.userName ?? 'Customer',
                      style: const TextStyle(
                        color: ColorConst.textLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (order.userEmail != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 24, top: 4),
                    child: Text(
                      order.userEmail!,
                      style: const TextStyle(
                        color: ColorConst.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorConst.bg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Order Total",
                        style: TextStyle(
                          color: ColorConst.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "₹${order.amount}",
                        style: const TextStyle(
                          color: ColorConst.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ACTION BUTTONS - Staff can only mark as PENDING or SUCCESS (No Cancel!)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ColorConst.surface.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  order.id,
                  'PENDING',
                  Colors.orange,
                  Icons.access_time_rounded,
                ),
                _actionButton(
                  order.id,
                  'PROCESSING',
                  Colors.blue,
                  Icons.sync_rounded,
                ),
                _actionButton(
                  order.id,
                  'SUCCESS',
                  Colors.greenAccent,
                  Icons.check_circle_rounded,
                ),
                // NO CANCEL BUTTON FOR STAFF!
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              status[0] + status.substring(1).toLowerCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
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
        color = Colors.blue;
        break;
      case 'CANCELLED':
        color = Colors.redAccent;
        break;
      default:
        color = Colors.orangeAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
