import 'dart:io';

import 'package:ecom/features/admin/products/controller/category_add_controller.dart';
import 'package:ecom/features/admin/products/controller/product_controller.dart';
import 'package:ecom/features/admin/products/controller/sub_category_controller.dart';
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
  final stockCtrl = TextEditingController();

  final RxnString selectedCategoryId = RxnString();
  final RxnString selectedSubCategoryId = RxnString();

  /// ✅ MULTIPLE IMAGES
  final RxList<File> selectedImages = <File>[].obs;

  /// =======================
  /// PICK MULTIPLE IMAGES
  /// =======================
  Future<void> pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(imageQuality: 80);

    if (images.isNotEmpty) {
      selectedImages.assignAll(images.map((e) => File(e.path)).toList());
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
            /// ================= IMAGE PICKER =================
            Obx(() {
              return GestureDetector(
                onTap: pickImages,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: selectedImages.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 40),
                              SizedBox(height: 8),
                              Text('Tap to select images'),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: selectedImages.length,
                          itemBuilder: (_, index) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    selectedImages[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      selectedImages.removeAt(index);
                                    },
                                    child: const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.black54,
                                      child: Icon(Icons.close,
                                          size: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              );
            }),

            const SizedBox(height: 20),

            /// ================= CATEGORY =================
            Obx(() {
              if (categoryCtrl.categories.isEmpty) {
                return const CircularProgressIndicator();
              }

              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                initialValue: selectedCategoryId.value,
                items: categoryCtrl.categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat['id'].toString(),
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

            /// ================= SUB CATEGORY =================
            Obx(() {
              if (selectedCategoryId.value == null) {
                return const SizedBox();
              }

              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Sub Category'),
                initialValue: selectedSubCategoryId.value,
                items: subCategoryCtrl.subCategories.map((sub) {
                  return DropdownMenuItem(
                    value: sub['id'].toString(),
                    child: Text(sub['name']),
                  );
                }).toList(),
                onChanged: (val) {
                  selectedSubCategoryId.value = val;
                },
              );
            }),

            const SizedBox(height: 16),

            /// ================= PRODUCT DETAILS =================
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),

            TextField(
              controller: descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),

            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),

            TextField(
              controller: stockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stock Quantity'),
            ),

            const SizedBox(height: 30),

            /// ================= SUBMIT =================
            Obx(() {
              return SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: productCtrl.isLoading.value
                      ? null
                      : () {
                          if (selectedImages.isEmpty ||
                              selectedCategoryId.value == null ||
                              selectedSubCategoryId.value == null ||
                              nameCtrl.text.isEmpty ||
                              priceCtrl.text.isEmpty ||
                              stockCtrl.text.isEmpty) {
                            Get.snackbar(
                                'Error', 'Please fill all fields');
                            return;
                          }

                          final stock =
                              int.tryParse(stockCtrl.text.trim());

                          if (stock == null || stock < 0) {
                            Get.snackbar(
                                'Error', 'Invalid stock value');
                            return;
                          }

                          productCtrl.addProduct(
                            name: nameCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            price:
                                double.parse(priceCtrl.text.trim()),
                            images: selectedImages,
                            categoryId:
                                selectedCategoryId.value!,
                            subCategoryId:
                                selectedSubCategoryId.value!,
                            stock: stock,
                          );
                        },
                  child: productCtrl.isLoading.value
                      ? const CircularProgressIndicator(
                          color: Colors.white)
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
