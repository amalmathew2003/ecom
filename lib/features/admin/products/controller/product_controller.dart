import 'dart:io';
import 'package:ecom/shared/models/product_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminProductController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final products = <ProductModel>[].obs;

  /// ================= FETCH =================
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
Future.microtask(() {
    Get.snackbar('Error', e.toString());
  });    } finally {
      isLoading.value = false;
    }
  }

  /// ================= ADD PRODUCT =================
  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required List<File> images,
    required String categoryId,
    required String subCategoryId,
    required int stock,
  }) async {
    try {
      isLoading.value = true;

      final List<String> imageUrls = [];

      for (final image in images) {
        final fileName =
            'products/${DateTime.now().microsecondsSinceEpoch}_${image.path.split('/').last}';

        final bytes = await image.readAsBytes();

        await supabase.storage
            .from('product-images')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(
                contentType: 'image/png',
                upsert: true,
              ),
            );

        imageUrls.add(
          supabase.storage.from('product-images').getPublicUrl(fileName),
        );
      }

      await supabase.from('products').insert({
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrls,
        'category_id': categoryId,
        'sub_category_id': subCategoryId,
        'stock': stock,
      });

      await fetchProducts();
      Get.snackbar('Success', 'Product added successfully');
    } catch (e) {
Future.microtask(() {
Future.microtask(() {
Future.microtask(() {
    Get.snackbar('Error', e.toString());
  });  });  });    } finally {
      isLoading.value = false;
    }
  }

  /// ================= UPDATE PRODUCT =================
  Future<bool> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    File? newimage,
    int? imageIndex,
    required List<String> imageUrl,
    required String categoryId,
    required String subCategoryId,
  }) async {
    try {
      isLoading.value = true;

      final updatedImages = List<String>.from(imageUrl);

      if (newimage != null && imageIndex != null) {
        final fileName =
            'products/${DateTime.now().microsecondsSinceEpoch}_${newimage.path.split('/').last}';

        final bytes = await newimage.readAsBytes();

        await supabase.storage
            .from('product-images')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(
                contentType: 'image/png',
                upsert: true,
              ),
            );

        updatedImages[imageIndex] = supabase.storage
            .from('product-images')
            .getPublicUrl(fileName);
      }

      await supabase
          .from('products')
          .update({
            'name': name,
            'description': description,
            'price': price,
            'stock': stock,
            'image_url': updatedImages,
            'category_id': categoryId,
            'sub_category_id': subCategoryId,
          })
          .eq('id', productId);

      await fetchProducts();
      return true;
    } catch (e) {
      if (kDebugMode) print(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= ADD IMAGE TO PRODUCT =================
  Future<bool> addimagetoProduct({
    required String productId,
    required File newImage,
    required List<String> existingImage,
  }) async {
    try {
      isLoading.value = true;

      final fileName =
          'products/${DateTime.now().microsecondsSinceEpoch}_${newImage.path.split('/').last}';

      final bytes = await newImage.readAsBytes();

      // Upload to Supabase Storage
      await supabase.storage
          .from('product-images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/png',
              upsert: true,
            ),
          );

      // Add new image URL to list
      final updatedImages = List<String>.from(existingImage)
        ..add(supabase.storage.from('product-images').getPublicUrl(fileName));

      // Update product row
      await supabase
          .from('products')
          .update({'image_url': updatedImages})
          .eq('id', productId);

      await fetchProducts();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Add image error: $e");
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= DELETE PRODUCT =================
  Future<bool> deleteProduct(String productId) async {
    try {
      isLoading.value = true;

      await supabase.from('products').delete().eq('id', productId);
      products.removeWhere((p) => p.id == productId);
      return true;
    } catch (e) {
      if (kDebugMode) print(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
