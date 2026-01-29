import 'dart:io';

import 'package:ecom/features/admin/products/controller/category_add_controller.dart';
import 'package:ecom/features/admin/products/controller/product_controller.dart';
import 'package:ecom/features/admin/products/controller/sub_category_controller.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
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
  final RxList<File> selectedImages = <File>[].obs;

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
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Add New Product',
          style: TextStyle(
            color: ColorConst.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ColorConst.textLight,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE PICKER SECTION
            const Text(
              'Product Gallery',
              style: TextStyle(
                color: ColorConst.textLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              return GestureDetector(
                onTap: pickImages,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ColorConst.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: ColorConst.surface,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: selectedImages.isEmpty
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_rounded,
                              size: 48,
                              color: ColorConst.primary,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Tap to upload images',
                              style: TextStyle(
                                color: ColorConst.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          scrollDirection: Axis.horizontal,
                          itemCount: selectedImages.length,
                          itemBuilder: (_, index) {
                            return Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 12),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      selectedImages[index],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () =>
                                          selectedImages.removeAt(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              );
            }),

            const SizedBox(height: 32),

            /// FORM SECTION
            const Text(
              'Product Details',
              style: TextStyle(
                color: ColorConst.textLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            /// CATEGORY DROPDOWNS
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    return _buildDropdown(
                      label: 'Category',
                      value: selectedCategoryId.value,
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() {
                    return _buildDropdown(
                      label: 'Sub Category',
                      value: selectedSubCategoryId.value,
                      disabled: selectedCategoryId.value == null,
                      items: subCategoryCtrl.subCategories.map((sub) {
                        return DropdownMenuItem(
                          value: sub['id'].toString(),
                          child: Text(sub['name']),
                        );
                      }).toList(),
                      onChanged: (val) => selectedSubCategoryId.value = val,
                    );
                  }),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildTextField(
              controller: nameCtrl,
              label: 'Product Name',
              icon: Icons.shopping_bag_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: descCtrl,
              label: 'Description',
              icon: Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: priceCtrl,
                    label: 'Price',
                    icon: Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: stockCtrl,
                    label: 'Stock',
                    icon: Icons.inventory_2_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            /// SUBMIT BUTTON
            Obx(() {
              return SizedBox(
                width: double.infinity,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: ColorConst.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: ColorConst.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: productCtrl.isLoading.value ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: productCtrl.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Launch Product',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (selectedImages.isEmpty ||
        selectedCategoryId.value == null ||
        selectedSubCategoryId.value == null ||
        nameCtrl.text.isEmpty ||
        priceCtrl.text.isEmpty ||
        stockCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    final stock = int.tryParse(stockCtrl.text.trim());
    if (stock == null || stock < 0) {
      Get.snackbar('Error', 'Invalid stock value');
      return;
    }

    productCtrl.addProduct(
      name: nameCtrl.text.trim(),
      description: descCtrl.text.trim(),
      price: double.parse(priceCtrl.text.trim()),
      images: selectedImages,
      categoryId: selectedCategoryId.value!,
      subCategoryId: selectedSubCategoryId.value!,
      stock: stock,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConst.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorConst.surface, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: ColorConst.textLight,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: ColorConst.textMuted),
          prefixIcon: Icon(icon, color: ColorConst.primary, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    bool disabled = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: disabled ? ColorConst.card.withOpacity(0.5) : ColorConst.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorConst.surface, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: value,
          dropdownColor: ColorConst.card,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: ColorConst.textMuted,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: ColorConst.textMuted),
            border: InputBorder.none,
          ),
          items: items,
          onChanged: disabled ? null : onChanged,
          style: const TextStyle(
            color: ColorConst.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
