import 'dart:io';

import 'package:ecom/features/admin/products/controller/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AdminAddProductPage extends StatelessWidget {
  AdminAddProductPage({super.key});

  final controller = Get.put(AdminProductController());

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final categories = ['Electronics', 'Fashion', 'Shoes', 'Accessories'];
  final RxString selectedCategory = 'Electronics'.obs;

  final Rx<File?> selectedImage = Rx<File?>(null);

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔹 Image Picker
            Obx(() {
              return GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: selectedImage.value == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 40),
                              SizedBox(height: 8),
                              Text('Tap to select image'),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            selectedImage.value!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              );
            }),

            const SizedBox(height: 20),
            Obx(() {
              return DropdownButtonFormField<String>(
                value: selectedCategory.value,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) selectedCategory.value = val;
                },
              );
            }),

            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),

            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),

            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),

            const SizedBox(height: 30),

            /// 🔹 Submit Button
            Obx(() {
              return SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (selectedImage.value == null) {
                            Get.snackbar('Error', 'Please select an image');
                            return;
                          }

                          controller.addProduct(
                            name: nameCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            price: double.parse(priceCtrl.text),
                            image: selectedImage.value!,
                            category: selectedCategory.value,
                          );
                        },
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Product'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
