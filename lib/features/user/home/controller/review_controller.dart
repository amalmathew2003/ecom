import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final reviews = [].obs;

  /// ================= FETCH REVIEWS =================
  Future<void> fetchReviews(String productId) async {
    try {
      isLoading.value = true;

      final response = await supabase
          .from('reviews')
          .select('reviewer_email, rating, comment, created_at')
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      reviews.assignAll(response);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= ADD / UPDATE REVIEW =================
  Future<void> submitReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    try {
      isLoading.value = true;

      await supabase.from('reviews').upsert({
        'user_id': supabase.auth.currentUser!.id,
        'product_id': productId,
        'rating': rating,
        'comment': comment,
        'reviewer_email': supabase.auth.currentUser!.email, // ✅ REAL EMAIL
      }, onConflict: 'user_id,product_id');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= MASK EMAIL / USER =================
  String maskEmail(String value) {
    // If not an email, show Verified Buyer
    if (!value.contains('@')) {
      return 'Verified Buyer';
    }

    final parts = value.split('@');
    final name = parts[0];

    if (name.length <= 2) {
      return value;
    }

    return '${name[0]}***${name[name.length - 1]}@${parts[1]}';
  }
}
