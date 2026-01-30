import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryDashboard extends StatefulWidget {
  const DeliveryDashboard({super.key});

  @override
  State<DeliveryDashboard> createState() => _DeliveryDashboardState();
}

class _DeliveryDashboardState extends State<DeliveryDashboard> {
  final supabase = Supabase.instance.client;
  final orders = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final selectedFilter = 'assigned'.obs;

  @override
  void initState() {
    super.initState();
    fetchMyDeliveries();
  }

  Future<void> fetchMyDeliveries() async {
    try {
      isLoading.value = true;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('orders')
          .select('*, customer:profiles!user_id(full_name, phone)')
          .eq('delivery_person', userId)
          .order('created_at', ascending: false);

      orders.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load deliveries: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateDeliveryStatus(String orderId, String status) async {
    try {
      await supabase
          .from('orders')
          .update({'delivery_status': status})
          .eq('id', orderId);

      Get.snackbar('Success', 'Delivery status updated to $status');
      fetchMyDeliveries();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status');
    }
  }

  List<Map<String, dynamic>> get filteredOrders {
    if (selectedFilter.value == 'all') return orders;
    return orders
        .where((o) => o['delivery_status'] == selectedFilter.value)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Deliveries',
          style: TextStyle(
            color: ColorConst.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: fetchMyDeliveries,
            icon: const Icon(Icons.refresh_rounded, color: ColorConst.primary),
          ),
          IconButton(
            onPressed: () async {
              await supabase.auth.signOut();
              Get.offAllNamed('/login');
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          ),
        ],
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: ColorConst.primary),
          );
        }

        return Column(
          children: [
            // Stats Header
            _buildStatsHeader(),

            // Filters
            _buildFilters(),

            // Delivery List
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchMyDeliveries,
                color: ColorConst.primary,
                child: filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredOrders.length,
                        itemBuilder: (_, index) =>
                            _buildDeliveryCard(filteredOrders[index]),
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatsHeader() {
    final pending = orders
        .where((o) => o['delivery_status'] == 'assigned')
        .length;
    final inTransit = orders
        .where((o) => o['delivery_status'] == 'in_transit')
        .length;
    final delivered = orders
        .where((o) => o['delivery_status'] == 'delivered')
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _statCard('Pending', pending.toString(), Colors.orange),
          const SizedBox(width: 12),
          _statCard('In Transit', inTransit.toString(), Colors.blue),
          const SizedBox(width: 12),
          _statCard('Delivered', delivered.toString(), Colors.green),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: ColorConst.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip('All', 'all'),
          _filterChip('Assigned', 'assigned'),
          _filterChip('Picked Up', 'picked_up'),
          _filterChip('In Transit', 'in_transit'),
          _filterChip('Delivered', 'delivered'),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    return Obx(() {
      final isSelected = selectedFilter.value == value;
      return GestureDetector(
        onTap: () => selectedFilter.value = value,
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? ColorConst.primary : ColorConst.card,
            borderRadius: BorderRadius.circular(12),
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
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 64,
            color: ColorConst.textMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No deliveries found',
            style: TextStyle(color: ColorConst.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> order) {
    final status = order['delivery_status'] ?? 'pending';
    final customer = order['customer'];
    final customerName = customer?['full_name'] ?? 'Customer';
    final customerPhone = customer?['phone'] ?? order['customer_phone'] ?? '';
    final address = order['shipping_address'] ?? 'No address provided';
    final amount = order['amount'] ?? 0;

    Color statusColor;
    switch (status) {
      case 'picked_up':
        statusColor = Colors.purple;
        break;
      case 'in_transit':
        statusColor = Colors.blue;
        break;
      case 'delivered':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ColorConst.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorConst.surface),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${order['id'].toString().substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        color: ColorConst.textLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.toUpperCase().replaceAll('_', ' '),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Customer Info
                Row(
                  children: [
                    const Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: ColorConst.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      customerName,
                      style: const TextStyle(
                        color: ColorConst.textLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(
                          color: ColorConst.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Amount & Phone
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹$amount',
                      style: const TextStyle(
                        color: ColorConst.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (customerPhone.isNotEmpty)
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('tel:$customerPhone')),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.call_rounded,
                                size: 14,
                                color: Colors.green,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Call',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          if (status != 'delivered')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ColorConst.surface.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _getActionButtons(order['id'], status),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _getActionButtons(String orderId, String currentStatus) {
    switch (currentStatus) {
      case 'assigned':
        return [
          _actionBtn(
            orderId,
            'picked_up',
            'Pick Up',
            Icons.inventory_2_rounded,
            Colors.purple,
          ),
        ];
      case 'picked_up':
        return [
          _actionBtn(
            orderId,
            'in_transit',
            'Start Delivery',
            Icons.local_shipping_rounded,
            Colors.blue,
          ),
        ];
      case 'in_transit':
        return [
          _actionBtn(
            orderId,
            'delivered',
            'Mark Delivered',
            Icons.check_circle_rounded,
            Colors.green,
          ),
        ];
      default:
        return [];
    }
  }

  Widget _actionBtn(
    String orderId,
    String status,
    String label,
    IconData icon,
    Color color,
  ) {
    return ElevatedButton.icon(
      onPressed: () => updateDeliveryStatus(orderId, status),
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
