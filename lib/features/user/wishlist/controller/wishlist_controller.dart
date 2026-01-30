import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WishlistController extends GetxController {
  final supabase = Supabase.instance.client;

  final wishlistItems = <String>[].obs; // List of product IDs in wishlist
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      isLoading.value = true;

      final response = await supabase
          .from('wishlist')
          .select('product_id')
          .eq('user_id', userId);

      wishlistItems.assignAll(
        (response as List).map((e) => e['product_id'].toString()).toList(),
      );
    } catch (e) {
      Get.log('Wishlist fetch error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool isInWishlist(String productId) {
    return wishlistItems.contains(productId);
  }

  Future<void> toggleWishlist(String productId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        Get.snackbar('Error', 'Please login to add to wishlist');
        return;
      }

      if (isInWishlist(productId)) {
        // Remove from wishlist
        await supabase
            .from('wishlist')
            .delete()
            .eq('user_id', userId)
            .eq('product_id', productId);

        wishlistItems.remove(productId);
        Get.snackbar('Removed', 'Item removed from wishlist');
      } else {
        // Add to wishlist
        await supabase.from('wishlist').insert({
          'user_id': userId,
          'product_id': productId,
        });

        wishlistItems.add(productId);
        Get.snackbar('Added', 'Item added to wishlist ❤️');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update wishlist');
    }
  }

  Future<void> clearWishlist() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      await supabase.from('wishlist').delete().eq('user_id', userId);
      wishlistItems.clear();
      Get.snackbar('Cleared', 'Wishlist cleared');
    } catch (e) {
      Get.snackbar('Error', 'Failed to clear wishlist');
    }
  }
}
