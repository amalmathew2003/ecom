import 'dart:io';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminProductController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  final isLoading = false.obs;

  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required File image,
    required String category,
  }) async {
    try {
      isLoading.value = true;

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
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

      await supabase.from('products').insert({
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'category': category, // ✅
      });

      Get.snackbar('Success', 'Product added');
    } catch (e) {
      Get.snackbar('Error', e.toString());
      print(" Error adding product: $e ");
    } finally {
      isLoading.value = false;
    }
  }
}
