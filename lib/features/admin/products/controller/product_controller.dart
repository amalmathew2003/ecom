import 'dart:io';
import 'package:ecom/shared/models/product_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminProductController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final products = <ProductModel>[].obs;

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('products')
          .select()
          .order('created_at', ascending: false);
      products.assignAll(
        (response as List).map((e) => ProductModel.fromJson(e)).toList(),
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required List<File> images, // ✅ FIXED
    required String categoryId,
    required String subCategoryId,
  }) async {
    try {
      isLoading.value = true;

      /// =======================
      /// UPLOAD MULTIPLE IMAGES
      /// =======================
      List<String> imageUrls = [];

      for (final image in images) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';

        final bytes = await image.readAsBytes();

        await supabase.storage
            .from('product-images')
            .uploadBinary(
              'products/$fileName',
              bytes,
              fileOptions: const FileOptions(
                contentType: 'image/png',
                upsert: true,
              ),
            );

        final imageUrl = supabase.storage
            .from('product-images')
            .getPublicUrl('products/$fileName');

        imageUrls.add(imageUrl);
      }

      /// =======================
      /// INSERT PRODUCT
      /// =======================
      await supabase.from('products').insert({
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrls, // ✅ TEXT[] (LIST)
        'category_id': categoryId,
        'sub_category_id': subCategoryId,
      });

      Get.snackbar('Success', 'Product added successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    File? newimage,
    required String categoryId,
    required String subCategoryId,
  }) async {
    try {
      isLoading.value = true;

      String? finalimageUrl;

      if (newimage != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
        final bytes = await newimage.readAsBytes();

        await supabase.storage
            .from('product-images')
            .uploadBinary(
              'products/$fileName',
              bytes,
              fileOptions: const FileOptions(
                contentType: 'image/png',
                upsert: true,
              ),
            );

        finalimageUrl = supabase.storage
            .from('product-images')
            .getPublicUrl('products/$fileName');
      }

      final data = {
        'name': name,
        'description': description,
        'price': price,
        'category_id': categoryId,
        'sub_category_id': subCategoryId,
        if (finalimageUrl != null) 'image_url': finalimageUrl,
      };

      final res = await supabase
          .from('products')
          .update(data)
          .eq('id', productId)
          .select();

      if (res.isEmpty) return false;

      await fetchProducts();

      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// =======================
  /// DELETE PRODUCT
  /// =======================
  Future<bool> deleteProduct(String productId) async {
    try {
      isLoading.value = true;

      final res = await supabase
          .from('products')
          .delete()
          .eq('id', productId)
          .select();

      if (res.isEmpty) return false;

      products.removeWhere((p) => p.id == productId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
