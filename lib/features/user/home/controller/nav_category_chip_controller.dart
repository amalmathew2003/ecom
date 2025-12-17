import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryController extends GetxController {
  final supabase = Supabase.instance.client;

  final categories = <Map<String, dynamic>>[].obs;
  final selectedIndex = 0.obs;

  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }

  Future<void> fetchCategories() async {
    final res = await supabase
        .from('categories')
        .select()
        .order('created_at');

    categories.value = [
      {'id': 'all', 'name': 'All'},
      ...List<Map<String, dynamic>>.from(res),
    ];
  }

  void select(int index) {
    selectedIndex.value = index;
  }
}
