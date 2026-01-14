import 'package:ecom/features/user/cart/data/card_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  final cartItems = <CartItemModel>[].obs;

  String get userId => supabase.auth.currentUser!.id;

  Future<void> fetchCart() async {
    try {
      final response = await supabase
          .from('cart')
          .select('id, quantity, products(*)')
          .eq('user_id', userId);

      // ✅ Use .assignAll AND call .refresh()
      cartItems.assignAll(
        (response as List).map((e) => CartItemModel.fromJson(e)).toList(),
      );
      cartItems.refresh();
    } catch (e) {
      print("Fetch Error: $e");
    }
  }


  /// ================= ADD TO CART =================
  Future<void> addToCart({
    required String productId,
    required int stock,
  }) async {
    final existing = await supabase
        .from('cart')
        .select()
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      final int currentQty = existing['quantity'];

      if (currentQty + 1 > stock) {
        Get.snackbar('Stock limit', 'No more stock available');
        return;
      }

      await supabase
          .from('cart')
          .update({'quantity': currentQty + 1})
          .eq('id', existing['id']);
    } else {
      await supabase.from('cart').insert({
        'user_id': userId,
        'product_id': productId,
        'quantity': 1,
      });
    }

    await fetchCart();
  }

  /// ================= INCREASE QTY (FIXED) =================
  Future<void> increaseQty(CartItemModel item) async {
    if (item.quantity + 1 > item.product.stock) {
      Get.snackbar('Stock limit', 'No more stock available');
      return;
    }

    final index = cartItems.indexWhere((e) => e.id == item.id);
    if (index == -1) return;

    final updatedItem = item.copyWith(quantity: item.quantity + 1);
    cartItems[index] = updatedItem; // ✅ REPLACE ITEM

    await supabase
        .from('cart')
        .update({'quantity': updatedItem.quantity})
        .eq('id', item.id);
  }

  /// ================= DECREASE QTY (FIXED) =================
  Future<void> decreaseQty(CartItemModel item) async {
    final index = cartItems.indexWhere((e) => e.id == item.id);
    if (index == -1) return;

    if (item.quantity <= 1) {
      cartItems.removeAt(index);
      await supabase.from('cart').delete().eq('id', item.id);
    } else {
      final updatedItem = item.copyWith(quantity: item.quantity - 1);
      cartItems[index] = updatedItem;

      await supabase
          .from('cart')
          .update({'quantity': updatedItem.quantity})
          .eq('id', item.id);
    }
  }

  /// ================= DELETE =================
  Future<void> deleteItem(String cartId) async {
    cartItems.removeWhere((e) => e.id == cartId);
    await supabase.from('cart').delete().eq('id', cartId);
  }

  ///
  bool isInCart(String productId) {
    return cartItems.any((item) => item.product.id == productId);
  }

  /// ================= TOTAL =================
  double get totalAmount => cartItems.fold(0, (sum, e) => sum + e.total);
}
