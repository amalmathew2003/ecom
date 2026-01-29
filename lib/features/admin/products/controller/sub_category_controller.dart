import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminSubCategoryController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var subCategories = <Map<String, dynamic>>[].obs;

  Future<void> fetchSubCategories(String categoryId) async {
    try {
      final res = await supabase
          .from('sub_categories')
          .select()
          .eq('category_id', categoryId)
          .order('created_at');
      subCategories.value = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("Error fetching sub-categories: $e");
    }
  }

  Future<void> addSubCategory({
    required String categoryId,
    required String name,
  }) async {
    if (name.trim().isEmpty) return;

    try {
      isLoading.value = true;
      await supabase.from('sub_categories').insert({
        'category_id': categoryId,
        'name': name.trim(),
      });
      await fetchSubCategories(categoryId);
      Get.snackbar('Success', 'Sub-category added');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSubCategory({
    required String id,
    required String categoryId,
  }) async {
    try {
      isLoading.value = true;
      await supabase.from('sub_categories').delete().eq('id', id);
      await fetchSubCategories(categoryId);
      Get.snackbar('Success', 'Sub-category deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete sub-category: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
