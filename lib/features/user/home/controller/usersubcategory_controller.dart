import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserSubCategoryController extends GetxController {
  final supabase = Supabase.instance.client;

  final subCategories = <Map<String, dynamic>>[].obs;
  final selectedIndex = (-1).obs;

  Future<void> fetchSubCategories(String categoryId) async {
    if (categoryId == 'all') {
      subCategories.clear();
      return;
    }

    final res = await supabase
        .from('sub_categories')
        .select()
        .eq('category_id', categoryId)
        .order('created_at');

    subCategories.value = List<Map<String, dynamic>>.from(res);
    selectedIndex.value = -1;
  }

  void select(int index) {
    selectedIndex.value = index;
  }
}
