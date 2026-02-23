import 'package:image_picker/image_picker.dart';
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
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= ADD PRODUCT =================
  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required List<XFile> images,
    XFile? video,
    required String categoryId,
    required String subCategoryId,
    required int stock,
  }) async {
    try {
      isLoading.value = true;

      final List<String> imageUrls = [];

      for (final image in images) {
        final fileName =
            'products/${DateTime.now().microsecondsSinceEpoch}_${image.name}';

        final bytes = await image.readAsBytes();

        await supabase.storage
            .from('product-images')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );

        imageUrls.add(
          supabase.storage.from('product-images').getPublicUrl(fileName),
        );
      }

      String? videoUrl;
      if (video != null) {
        final videoFileName =
            'videos/${DateTime.now().microsecondsSinceEpoch}_${video.name}';
        final videoBytes = await video.readAsBytes();
        await supabase.storage
            .from('product-images')
            .uploadBinary(
              videoFileName,
              videoBytes,
              fileOptions: const FileOptions(
                upsert: true,
                contentType: 'video/mp4',
              ),
            );
        videoUrl = supabase.storage
            .from('product-images')
            .getPublicUrl(videoFileName);
      }

      await supabase.from('products').insert({
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrls,
        'video_url': videoUrl,
        'category_id': categoryId,
        'sub_category_id': subCategoryId,
        'stock': stock,
      });

      await fetchProducts();
      Get.snackbar('Success', 'Product added successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
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
    XFile? newimage,
    XFile? newVideo,
    int? imageIndex,
    required List<String> imageUrl,
    String? currentVideoUrl,
    required String categoryId,
    required String subCategoryId,
  }) async {
    try {
      isLoading.value = true;

      final updatedImages = List<String>.from(imageUrl);

      if (newimage != null && imageIndex != null) {
        final fileName =
            'products/${DateTime.now().microsecondsSinceEpoch}_${newimage.name}';

        final bytes = await newimage.readAsBytes();

        await supabase.storage
            .from('product-images')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );

        updatedImages[imageIndex] = supabase.storage
            .from('product-images')
            .getPublicUrl(fileName);
      }

      String? updatedVideoUrl = currentVideoUrl;
      if (newVideo != null) {
        final videoFileName =
            'videos/${DateTime.now().microsecondsSinceEpoch}_${newVideo.name}';
        final videoBytes = await newVideo.readAsBytes();
        await supabase.storage
            .from('product-images')
            .uploadBinary(
              videoFileName,
              videoBytes,
              fileOptions: const FileOptions(
                upsert: true,
                contentType: 'video/mp4',
              ),
            );
        updatedVideoUrl = supabase.storage
            .from('product-images')
            .getPublicUrl(videoFileName);
      }

      await supabase
          .from('products')
          .update({
            'name': name,
            'description': description,
            'price': price,
            'stock': stock,
            'image_url': updatedImages,
            'video_url': updatedVideoUrl,
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
    required XFile newImage,
    required List<String> existingImage,
  }) async {
    try {
      isLoading.value = true;

      final fileName =
          'products/${DateTime.now().microsecondsSinceEpoch}_${newImage.name}';

      final bytes = await newImage.readAsBytes();

      // Upload to Supabase Storage
      await supabase.storage
          .from('product-images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
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

  /// ================= UPDATE/ADD VIDEO TO PRODUCT =================
  Future<bool> updateVideoToProduct({
    required String productId,
    required XFile newVideo,
  }) async {
    try {
      isLoading.value = true;

      final fileName =
          'videos/${DateTime.now().microsecondsSinceEpoch}_${newVideo.name}';
      final bytes = await newVideo.readAsBytes();

      await supabase.storage
          .from('product-images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'video/mp4',
            ),
          );

      final videoUrl = supabase.storage
          .from('product-images')
          .getPublicUrl(fileName);

      await supabase
          .from('products')
          .update({'video_url': videoUrl})
          .eq('id', productId);

      await fetchProducts();
      return true;
    } catch (e) {
      if (kDebugMode) print("Add video error: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
