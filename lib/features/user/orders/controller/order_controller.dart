import 'package:ecom/features/user/orders/data/order_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderController extends GetxController {
  final supabase = Supabase.instance.client;

  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders(); // ✅ AUTO LOAD
  }

  Future<void> fetchOrders() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      isLoading.value = true;

      final response = await supabase
          .from('orders')
          .select(
            '*, customer:profiles!user_id(full_name, email), manager:managed_by(full_name), order_items(*, products(*))',
          )
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      Get.log(
        "📦 DEBUG: Fetched ${response.length} orders for user ${user.id}",
      );

      orders.assignAll(
        (response as List).map((e) => OrderModel.fromJson(e)).toList(),
      );
    } catch (e) {
      Get.log("❌ Order Fetch Error: $e");
      Get.snackbar(
        'Order Sync Error',
        'We couldn\'t load your purchase history. Try pulling to refresh.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    await supabase
        .from('orders')
        .update({'payment_status': 'CANCELLED'})
        .eq('id', orderId);

    fetchOrders();
  }
}
