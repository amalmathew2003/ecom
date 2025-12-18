import 'dart:io';
import 'package:ecom/features/admin/products/controller/product_controller.dart';
import 'package:ecom/shared/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AdminEditProductPage extends StatefulWidget {
  final ProductModel product;

  const AdminEditProductPage({super.key, required this.product});

  @override
  State<AdminEditProductPage> createState() => _AdminEditProductPageState();
}

class _AdminEditProductPageState extends State<AdminEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  late TextEditingController nameCtrl;
  late TextEditingController descCtrl;
  late TextEditingController priceCtrl;

  File? selectedImage;

  late final AdminProductController productCtrl;

  @override
  void initState() {
    super.initState();

    productCtrl = Get.find<AdminProductController>();

    nameCtrl = TextEditingController(text: widget.product.name);
    descCtrl = TextEditingController(text: widget.product.description);
    priceCtrl = TextEditingController(text: widget.product.price.toString());
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  void updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await productCtrl.updateProduct(
      productId: widget.product.id,
      name: nameCtrl.text.trim(),
      description: descCtrl.text.trim(),
      price: double.parse(priceCtrl.text.trim()),
      newimage: selectedImage,
      categoryId: widget.product.categoryId,
      subCategoryId: widget.product.subCategoryId,
    );

    if (success) {
      Get.back(); // ✅ NOW it will go back

      Get.snackbar(
        'Success',
        'Product updated successfully',
        snackPosition: SnackPosition.TOP,
      );
    } else {
      Get.snackbar(
        'Failed',
        'Product update failed',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// IMAGE
              GestureDetector(
                onTap: pickImage,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: selectedImage != null
                      ? Image.file(
                          selectedImage!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          widget.product.imageUrl,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              const Text("Tap image to change"),

              const SizedBox(height: 20),

              /// NAME
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Product Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? "Enter name" : null,
              ),

              const SizedBox(height: 12),

              /// DESCRIPTION
              TextFormField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              /// PRICE
              TextFormField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? "Enter price" : null,
              ),

              const SizedBox(height: 24),

              /// SAVE BUTTON
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: productCtrl.isLoading.value
                        ? null
                        : updateProduct,
                    child: productCtrl.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Update Product"),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
