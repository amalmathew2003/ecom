import 'dart:io';
import 'package:ecom/features/admin/products/controller/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AdminEditProductPage extends StatefulWidget {
  final String productId;

  const AdminEditProductPage({super.key, required this.productId});

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
  int currentImageIndex = 0;

  final productCtrl = Get.find<AdminProductController>();

  @override
  void initState() {
    super.initState();

    final product = productCtrl.products.firstWhere(
      (p) => p.id == widget.productId,
    );

    nameCtrl = TextEditingController(text: product.name);
    descCtrl = TextEditingController(text: product.description);
    priceCtrl = TextEditingController(text: product.price.toString());
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<void> updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final product = productCtrl.products.firstWhere(
      (p) => p.id == widget.productId,
    );

    final success = await productCtrl.updateProduct(
      productId: product.id,
      name: nameCtrl.text,
      description: descCtrl.text,
      price: double.parse(priceCtrl.text),
      newimage: selectedImage,
      imageIndex: currentImageIndex,
      imageUrl: product.imageUrl,
      categoryId: product.categoryId,
      subCategoryId: product.subCategoryId,
    );

    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        'Product updated successfully',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF192230),

      appBar: AppBar(
        backgroundColor: const Color(0xFF192230),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Edit Product",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.4),
        ),
      ),

      body: Obx(() {
        final product = productCtrl.products.firstWhere(
          (p) => p.id == widget.productId,
        );

        final images = product.imageUrl;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// IMAGE SECTION
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: MediaQuery.sizeOf(context).height * .40,
                        width: double.infinity,
                        child: selectedImage != null
                            ? Image.file(selectedImage!, fit: BoxFit.cover)
                            : PageView.builder(
                                itemCount: images.length,
                                onPageChanged: (i) {
                                  currentImageIndex = i;
                                },
                                itemBuilder: (_, index) {
                                  return Image.network(
                                    images[index],
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                      ),
                    ),

                    /// IMAGE BUTTONS
                    Positioned(
                      bottom: 14,
                      right: 14,
                      child: _iconButton(icon: Icons.edit, onTap: pickImage),
                    ),
                    Positioned(
                      bottom: 14,
                      left: 14,
                      child: _iconButton(
                        icon: Icons.add,
                        onTap: () async {
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (picked == null) return;

                          await productCtrl.addimagetoProduct(
                            productId: product.id,
                            newImage: File(picked.path),
                            existingImage: product.imageUrl,
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                /// INPUTS
                _modernField(
                  controller: nameCtrl,
                  label: "Product Name",
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter name" : null,
                ),
                const SizedBox(height: 14),

                _modernField(
                  controller: descCtrl,
                  label: "Description",
                  maxLines: 3,
                ),
                const SizedBox(height: 14),

                _modernField(
                  controller: priceCtrl,
                  label: "Price",
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 28),

                /// UPDATE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: productCtrl.isLoading.value
                        ? null
                        : updateProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCD00),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: productCtrl.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "Update Product",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// UI ONLY
  Widget _modernField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFB0B6BE)),
        filled: true,
        fillColor: const Color(0xFF2C2F38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// UI ONLY
  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFCD00),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: .3), blurRadius: 6),
          ],
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}
