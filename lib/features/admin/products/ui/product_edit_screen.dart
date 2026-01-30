import 'dart:io';
import 'package:ecom/features/admin/products/controller/product_controller.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
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
  late TextEditingController stockCtrl;

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
    stockCtrl = TextEditingController(text: product.stock.toString());
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

    final stock = int.tryParse(stockCtrl.text.trim());

    if (stock == null || stock < 0) {
      Get.snackbar('Error', 'Invalid stock value');
      return;
    }

    final success = await productCtrl.updateProduct(
      productId: product.id,
      name: nameCtrl.text.trim(),
      description: descCtrl.text.trim(),
      price: double.parse(priceCtrl.text.trim()),
      stock: stock,
      newimage: selectedImage,
      imageIndex: currentImageIndex,
      imageUrl: product.imageUrl,
      categoryId: product.categoryId,
      subCategoryId: product.subCategoryId,
    );

    if (success) {
      Get.back();
      Get.snackbar('Success', 'Product updated successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Edit Product",
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
      body: Obx(() {
        final product = productCtrl.products.firstWhere(
          (p) => p.id == widget.productId,
        );

        final images = product.imageUrl;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// IMAGE SECTION
                const Text(
                  'Product Media',
                  style: TextStyle(
                    color: ColorConst.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Container(
                      height: MediaQuery.sizeOf(context).height * .35,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: ColorConst.card,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: ColorConst.surface, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: selectedImage != null
                            ? Image.file(selectedImage!, fit: BoxFit.cover)
                            : PageView.builder(
                                itemCount: images.length,
                                onPageChanged: (i) => currentImageIndex = i,
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
                      bottom: 12,
                      right: 12,
                      child: _circleActionButton(
                        icon: Icons.edit_rounded,
                        color: ColorConst.accent,
                        onTap: pickImage,
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 64,
                      child: _circleActionButton(
                        icon: Icons.add_photo_alternate_rounded,
                        color: ColorConst.primary,
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

                const SizedBox(height: 32),

                /// INPUTS SECTION
                const Text(
                  'Product Details',
                  style: TextStyle(
                    color: ColorConst.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                _buildModernField(
                  controller: nameCtrl,
                  label: "Product Name",
                  icon: Icons.shopping_bag_outlined,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter name" : null,
                ),
                const SizedBox(height: 16),

                _buildModernField(
                  controller: descCtrl,
                  label: "Description",
                  icon: Icons.description_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildModernField(
                        controller: priceCtrl,
                        label: "Price",
                        icon: Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModernField(
                        controller: stockCtrl,
                        label: "Stock",
                        icon: Icons.inventory_2_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? "Required" : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                /// UPDATE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: ColorConst.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: ColorConst.primary.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: productCtrl.isLoading.value
                          ? null
                          : updateProduct,
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
                              "Save Changes",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConst.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorConst.surface, width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
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

  Widget _circleActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ColorConst.card,
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
