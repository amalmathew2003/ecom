import 'package:ecom/features/user/orders/data/oder_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminOrderController extends GetxController {
  final supabase = Supabase.instance.client;

  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final totalRevenue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllOrders();
  }

  Future<void> fetchAllOrders() async {
    isLoading.value = true;
    try {
      // 1. Try fetching with joins (full detail)
      try {
        final response = await supabase
            .from('orders')
            .select(
              '*, profiles(full_name, email), manager:managed_by(full_name)',
            )
            .order('created_at', ascending: false);

        _processOrders(response as List);
      } catch (e) {
        print("Complex fetch failed, trying simple fetch: $e");

        // 2. Fallback: Try fetching without relationships (in case DB schema isn't fully set up)
        final simpleResponse = await supabase
            .from('orders')
            .select()
            .order('created_at', ascending: false);

        _processOrders(simpleResponse as List);
      }
    } catch (e) {
      print("CRITICAL: Error fetching orders: $e");
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

    // Calculate revenue from SUCCESS orders
    double total = 0;
    for (var order in fetchedOrders) {
      if (order.status == 'SUCCESS') {
        total += order.amount;
      }
    }
    totalRevenue.value = total;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final adminId = supabase.auth.currentUser?.id;

      await supabase
          .from('orders')
          .update({'payment_status': status, 'managed_by': adminId})
          .eq('id', orderId);

      await fetchAllOrders();
      Get.snackbar('Success', 'Order status updated to $status');
    } catch (e) {
      // Fallback update if managed_by column is missing
      try {
        await supabase
            .from('orders')
            .update({'payment_status': status})
            .eq('id', orderId);

        await fetchAllOrders();
        Get.snackbar('Success', 'Order status updated (managed_by skipped)');
      } catch (e2) {
        Get.snackbar('Error', 'Failed to update order status: $e2');
      }
    }
  }
}
