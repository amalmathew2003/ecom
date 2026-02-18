import 'package:ecom/features/user/orders/data/order_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminOrderController extends GetxController {
  final supabase = Supabase.instance.client;

  final orders = <OrderModel>[].obs;
  final filteredOrders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final totalRevenue = 0.0.obs;
  final selectedFilter = 'ALL'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllOrders();
    fetchDeliveryPersonnel();
  }

  Future<void> fetchAllOrders() async {
    isLoading.value = true;
    try {
      // 1. Try fetching with joins (full detail)
      try {
        final response = await supabase
            .from('orders')
            .select(
              '*, customer:profiles!user_id(full_name, email), manager:profiles!managed_by(full_name), order_items(*, products(*))',
            )
            .order('created_at', ascending: false);

        _processOrders(response as List);
      } catch (e) {
        Get.log("Complex fetch failed, trying simple fetch: $e");

        // 2. Fallback: Try fetching without relationships (in case DB schema isn't fully set up)
        final simpleResponse = await supabase
            .from('orders')
            .select()
            .order('created_at', ascending: false);

        _processOrders(simpleResponse as List);
      }
    } catch (e) {
      Get.log("CRITICAL: Error fetching orders: $e");
      Get.snackbar(
        'Connection Error',
        'Please check your internet and Supabase tables.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _processOrders(List data) {
    final fetchedOrders = data.map((e) => OrderModel.fromJson(e)).toList();
    orders.assignAll(fetchedOrders);
    applyFilter(selectedFilter.value);

    // Calculate revenue from SUCCESS orders
    double total = 0;
    for (var order in fetchedOrders) {
      if (order.status == 'SUCCESS') {
        total += order.amount;
      }
    }
    totalRevenue.value = total;
  }

  void applyFilter(String filter) {
    selectedFilter.value = filter;
    if (filter == 'ALL') {
      filteredOrders.assignAll(orders);
    } else {
      filteredOrders.assignAll(
        orders.where((order) => order.status == filter).toList(),
      );
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final adminId = supabase.auth.currentUser?.id;

      // Try with 'status' column first (newer schema)
      try {
        await supabase
            .from('orders')
            .update({'status': status, 'managed_by': adminId})
            .eq('id', orderId);

        await fetchAllOrders();
        Get.snackbar('Success', 'Order status updated to $status');
        return;
      } catch (e) {
        Get.log("Update with 'status' failed: $e");
      }

      // Fallback 1: Try with 'payment_status' column (older schema)
      try {
        await supabase
            .from('orders')
            .update({'payment_status': status, 'managed_by': adminId})
            .eq('id', orderId);

        await fetchAllOrders();
        Get.snackbar('Success', 'Order status updated to $status');
        return;
      } catch (e) {
        Get.log("Update with 'payment_status' and managed_by failed: $e");
      }

      // Fallback 2: Try without managed_by (in case column doesn't exist)
      try {
        await supabase
            .from('orders')
            .update({'status': status})
            .eq('id', orderId);

        await fetchAllOrders();
        Get.snackbar('Success', 'Order status updated');
        return;
      } catch (e) {
        Get.log("Update with 'status' only failed: $e");
      }

      // Fallback 3: Last attempt with payment_status only
      try {
        await supabase
            .from('orders')
            .update({'payment_status': status})
            .eq('id', orderId);

        await fetchAllOrders();
        Get.snackbar('Success', 'Order status updated');
        return;
      } catch (e) {
        Get.log("All update attempts failed: $e");
      }

      // If all attempts fail, show error
      Get.snackbar(
        'Error',
        'Failed to update order status. Please check database schema.',
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order status: $e');
    }
  }

  // ============= DELIVERY MANAGEMENT =============

  final deliveryPersonnel = <Map<String, dynamic>>[].obs;

  Future<void> fetchDeliveryPersonnel() async {
    try {
      final response = await supabase
          .from('profiles')
          .select('id, full_name, email')
          .neq('role', 'admin');

      deliveryPersonnel.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.log('Error fetching delivery personnel: $e');
    }
  }

  Future<void> assignDeliveryPerson(
    String orderId,
    String deliveryPersonId,
  ) async {
    try {
      // 1. Update delivery info
      await supabase
          .from('orders')
          .update({
            'delivery_person': deliveryPersonId,
            'delivery_status': 'assigned',
          })
          .eq('id', orderId);

      // 2. Automatically change status to OUT_FOR_DELIVERY
      try {
        await supabase
            .from('orders')
            .update({'status': 'OUT_FOR_DELIVERY'})
            .eq('id', orderId);
      } catch (e) {
        // Fallback to payment_status if status column doesn't exist
        await supabase
            .from('orders')
            .update({'payment_status': 'OUT_FOR_DELIVERY'})
            .eq('id', orderId);
      }

      await fetchAllOrders();
      Get.snackbar('Success', 'Delivery partner assigned & order updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to assign delivery person: $e');
    }
  }
}
