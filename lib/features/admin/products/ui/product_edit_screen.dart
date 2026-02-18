import 'dart:io';
import 'package:ecom/features/admin/products/controller/product_controller.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:ecom/core/utils/responsive_layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      setState(() => selectedImage = File(picked.path));
    }
  }

  Future<void> updateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    final product = productCtrl.products.firstWhere(
      (p) => p.id == widget.productId,
    );
    final stock = int.tryParse(stockCtrl.text.trim());
    if (stock == null || stock < 0) {
      Get.snackbar(
        'ENTRY ERROR',
        'INVALID STOCK COUNT',
        backgroundColor: NeoColors.error.withOpacity(0.1),
        colorText: NeoColors.error,
      );
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
      Get.snackbar(
        'SUCCESS',
        'PRODUCT INTEL UPDATED',
        backgroundColor: Colors.greenAccent.withOpacity(0.1),
        colorText: Colors.greenAccent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.background,
      body: ResponsiveLayout(
        child: Obx(() {
          final product = productCtrl.products.firstWhere(
            (p) => p.id == widget.productId,
          );
          final images = product.imageUrl;

          return Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle("PRODUCT MEDIA"),
                        const SizedBox(height: 15),
                        _buildImageHero(images, product),
                        const SizedBox(height: 40),
                        _sectionTitle("STORE SPECIFICATIONS"),
                        const SizedBox(height: 20),
                        _buildForm(),
                        const SizedBox(height: 60),
                        _buildUpdateBtn(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: NeoColors.textHigh,
            ),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 15),
          Text(
            "EDIT PRODUCT",
            style: GoogleFonts.oswald(
              color: NeoColors.textHigh,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.oswald(
        color: NeoColors.textLow,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildImageHero(List<String> images, product) {
    return Stack(
      children: [
        Container(
          height: 350,
          width: double.infinity,
          decoration: BoxDecoration(
            color: NeoColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: selectedImage != null
                ? Image.file(selectedImage!, fit: BoxFit.cover)
                : PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => currentImageIndex = i),
                    itemBuilder: (_, index) =>
                        Image.network(images[index], fit: BoxFit.cover),
                  ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: Row(
            children: [
              _circleActionButton(
                icon: Icons.edit_rounded,
                color: NeoColors.accent,
                onTap: pickImage,
              ),
              const SizedBox(width: 12),
              _circleActionButton(
                icon: Icons.add_photo_alternate_rounded,
                color: Colors.purpleAccent,
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildTextField(
          controller: nameCtrl,
          label: 'PRODUCT NAME',
          icon: Icons.shopping_bag_outlined,
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: descCtrl,
          label: 'DESCRIPTION',
          icon: Icons.description_outlined,
          maxLines: 5,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: priceCtrl,
                label: 'PRICE (₹)',
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildTextField(
                controller: stockCtrl,
                label: 'STOCK',
                icon: Icons.inventory_2_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: NeoColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.montserrat(
          color: NeoColors.textHigh,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.oswald(
            color: NeoColors.textLow,
            fontSize: 12,
            letterSpacing: 1,
          ),
          prefixIcon: Icon(icon, color: NeoColors.accent, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: NeoColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _buildUpdateBtn() {
    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: NeoColors.premiumGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: NeoColors.accent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: productCtrl.isLoading.value ? null : updateProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: productCtrl.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                "SAVE MODIFICATIONS",
                style: GoogleFonts.oswald(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
      ),
    ).animate().scale();
  }
}
