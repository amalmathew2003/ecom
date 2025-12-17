import 'dart:io';

import 'package:ecom/features/admin/products/controller/category_add_controller.dart';
import 'package:ecom/features/admin/products/controller/sub_category_controller.dart';
import 'package:ecom/features/admin/products/controller/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AdminAddProductPage extends StatelessWidget {
  AdminAddProductPage({super.key});

  final productCtrl = Get.put(AdminProductController());
  final categoryCtrl = Get.put(AdminCategoryController());
  final subCategoryCtrl = Get.put(AdminSubCategoryController());

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  final RxnString selectedCategoryId = RxnString();
  final RxnString selectedSubCategoryId = RxnString();

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
            /// =======================
            /// IMAGE PICKER
            /// =======================
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

            /// =======================
            /// CATEGORY DROPDOWN
            /// =======================
            Obx(() {
              if (categoryCtrl.categories.isEmpty) {
                return const CircularProgressIndicator();
              }

              return DropdownButtonFormField<String>(
                value: selectedCategoryId.value,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categoryCtrl.categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat['id'].toString(), // ✅ UUID
                    child: Text(cat['name']),
                  );
                }).toList(),
                onChanged: (val) {
                  selectedCategoryId.value = val;
                  selectedSubCategoryId.value = null;
                  subCategoryCtrl.fetchSubCategories(val!);
                },
              );
            }),

            const SizedBox(height: 16),

            /// =======================
            /// SUB CATEGORY DROPDOWN
            /// =======================
            Obx(() {
              if (selectedCategoryId.value == null) {
                return const SizedBox();
              }

              return DropdownButtonFormField<String>(
                value: selectedSubCategoryId.value,
                decoration:
                    const InputDecoration(labelText: 'Sub Category'),
                items: subCategoryCtrl.subCategories.map((sub) {
                  return DropdownMenuItem<String>(
                    value: sub['id'].toString(), // ✅ UUID
                    child: Text(sub['name']),
                  );
                }).toList(),
                onChanged: (val) {
                  selectedSubCategoryId.value = val;
                },
              );
            }),

            const SizedBox(height: 16),

            /// =======================
            /// PRODUCT DETAILS
            /// =======================
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

            /// =======================
            /// SUBMIT BUTTON
            /// =======================
            Obx(() {
              return SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: productCtrl.isLoading.value
                      ? null
                      : () {
                          if (selectedImage.value == null ||
                              selectedCategoryId.value == null ||
                              selectedSubCategoryId.value == null) {
                            Get.snackbar(
                              'Error',
                              'Please fill all fields',
                            );
                            return;
                          }

                          productCtrl.addProduct(
                            name: nameCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            price: double.parse(priceCtrl.text),
                            image: selectedImage.value!,
                            categoryId: selectedCategoryId.value!,
                            subCategoryId: selectedSubCategoryId.value!,
                          );
                        },
                  child: productCtrl.isLoading.value
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
