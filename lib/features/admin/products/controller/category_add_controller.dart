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
    final res = await supabase
        .from('categories')
        .select()
        .order('created_at');

    categories.value = List<Map<String, dynamic>>.from(res);
  }

  Future<void> addCategory(String name) async {
    if (name.trim().isEmpty) return;

    try {
      isLoading.value = true;

      await supabase.from('categories').insert({
        'name': name.trim(),
      });

      await fetchCategories();
      Get.snackbar('Success', 'Category added');
    } catch (e) {
Future.microtask(() {
   Future.microtask(() {
    Get.snackbar('Error', e.toString());
  });
  });    } finally {
      isLoading.value = false;
    }
  }
}
