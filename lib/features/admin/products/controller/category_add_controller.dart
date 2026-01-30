import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminCategoryController extends GetxController {
  final supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final categories = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final res = await supabase
          .from('categories')
          .select()
          .order('created_at');
      categories.value = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      Get.log("Error fetching categories: $e");
    }
  }

  Future<void> addCategory(String name) async {
    if (name.trim().isEmpty) return;

    try {
      isLoading.value = true;
      await supabase.from('categories').insert({'name': name.trim()});
      await fetchCategories();
      Get.snackbar('Success', 'Category added');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      isLoading.value = true;
      await supabase.from('categories').delete().eq('id', id);
      await fetchCategories();
      Get.snackbar('Success', 'Category deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete category: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
