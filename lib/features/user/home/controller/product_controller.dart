import 'package:ecom/shared/models/product_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductController extends GetxController {
  final supabase = Supabase.instance.client;

  final products = <ProductModel>[].obs;
  final newArrivals = <ProductModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    fetchProducts(); // All products
    fetchNewArrivals(); // Latest 5
    super.onInit();
  }

  /// 🔹 Fetch products with optional category filter
  Future<void> fetchProducts({String categoryId = 'all'}) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 200));

      var query = supabase.from('products').select();

      if (categoryId != 'all') {
        query = query.eq('category_id', categoryId);
      }

      final response = await query.order('created_at', ascending: false);

      products.value = (response as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 New Arrivals (latest 5 products)
  Future<void> fetchNewArrivals() async {
    try {
      final sevenDaysAgo = DateTime.now()
          .subtract(const Duration(days: 14))
          .toIso8601String();

      final response = await supabase
          .from('products')
          .select()
          .gte('created_at', sevenDaysAgo) // ✅ only last 7 days
          .order('created_at', ascending: false)
          .limit(5);

      newArrivals.value = (response as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> fetchProductsBySubCategory({
    required String subCategoryId,
  }) async {
    try {
      isLoading.value = true;

      final response = await supabase
          .from('products')
          .select()
          .eq('sub_category_id', subCategoryId)
          .order('created_at', ascending: false);

      products.value = (response as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  //sort price low to high
  void sortByPriceLowToHigh() {
    products.sort((a, b) => a.price.compareTo(b.price));
  }

  void sortByPriceHighToLow() {
    products.sort((a, b) => b.price.compareTo(a.price));
  }
}
