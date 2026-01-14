import 'package:ecom/features/user/orders/data/oder_model.dart';
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
    final user = supabase.auth.currentUser;
    if (user == null) return;

    isLoading.value = true;

    final response = await supabase
        .from('orders')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    orders.assignAll(
      (response as List).map((e) => OrderModel.fromJson(e)).toList(),
    );
    print("Orders count: ${response.length}");

    isLoading.value = false;
  }
}
