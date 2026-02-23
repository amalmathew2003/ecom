import 'dart:io';
import 'package:ecom/features/admin/products/controller/category_add_controller.dart';
import 'package:ecom/features/admin/products/controller/product_controller.dart';
import 'package:ecom/features/admin/products/controller/sub_category_controller.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:ecom/core/utils/responsive_layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

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
  final RxList<XFile> selectedImages = <XFile>[].obs;
  final Rxn<XFile> selectedVideo = Rxn<XFile>();

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      selectedImages.assignAll(images);
    }
  }

  Future<void> pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      selectedVideo.value = video;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.background,
      body: ResponsiveLayout(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("PRODUCT GALLERY"),
                    const SizedBox(height: 15),
                    _buildImagePicker(),
                    const SizedBox(height: 20),
                    _sectionTitle("PRODUCT VIDEO"),
                    const SizedBox(height: 15),
                    _buildVideoPicker(),
                    const SizedBox(height: 40),
                    _sectionTitle("SPECIFICATIONS"),
                    const SizedBox(height: 20),
                    _buildForm(),
                    const SizedBox(height: 60),
                    _buildSubmitBtn(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            "NEW PRODUCT",
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

  Widget _buildVideoPicker() {
    return Obx(() {
      return GestureDetector(
        onTap: pickVideo,
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: NeoColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 2),
          ),
          child: selectedVideo.value == null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.video_call_rounded,
                      size: 30,
                      color: Colors.purpleAccent.withOpacity(0.5),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      "UPLOAD MOTION ASSET",
                      style: GoogleFonts.oswald(
                        color: NeoColors.textLow,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.movie_creation_outlined,
                            color: Colors.purpleAccent,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              selectedVideo.value!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                color: NeoColors.textHigh,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => selectedVideo.value = null,
                        child: Container(
                          padding: const EdgeInsets.all(5),
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
        ),
      );
    });
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

  Widget _buildImagePicker() {
    return Obx(() {
      return GestureDetector(
        onTap: pickImages,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: NeoColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 2),
          ),
          child: selectedImages.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 50,
                      color: NeoColors.accent.withOpacity(0.5),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "UPLOAD ASSETS",
                      style: GoogleFonts.oswald(
                        color: NeoColors.textLow,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedImages.length,
                  itemBuilder: (_, index) => _imagePreview(index),
                ),
        ),
      );
    });
  }

  Widget _imagePreview(int index) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: kIsWeb
                ? Image.network(
                    selectedImages[index].path,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Image.file(
                    File(selectedImages[index].path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () => selectedImages.removeAt(index),
              child: Container(
                padding: const EdgeInsets.all(5),
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
  }

  Widget _buildForm() {
    final isMobile = ResponsiveLayout.isMobile(Get.context!);
    return Column(
      children: [
        if (isMobile) ...[
          Obx(
            () => _buildDropdown(
              label: 'CATEGORY',
              value: selectedCategoryId.value,
              items: categoryCtrl.categories
                  .map(
                    (cat) => DropdownMenuItem(
                      value: cat['id'].toString(),
                      child: Text(cat['name'].toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                selectedCategoryId.value = val;
                selectedSubCategoryId.value = null;
                subCategoryCtrl.fetchSubCategories(val!);
              },
            ),
          ),
          const SizedBox(height: 15),
          Obx(
            () => _buildDropdown(
              label: 'SUB CATEGORY',
              value: selectedSubCategoryId.value,
              disabled: selectedCategoryId.value == null,
              items: subCategoryCtrl.subCategories
                  .map(
                    (sub) => DropdownMenuItem(
                      value: sub['id'].toString(),
                      child: Text(sub['name'].toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (val) => selectedSubCategoryId.value = val,
            ),
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildDropdown(
                    label: 'CATEGORY',
                    value: selectedCategoryId.value,
                    items: categoryCtrl.categories
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat['id'].toString(),
                            child: Text(cat['name'].toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      selectedCategoryId.value = val;
                      selectedSubCategoryId.value = null;
                      subCategoryCtrl.fetchSubCategories(val!);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Obx(
                  () => _buildDropdown(
                    label: 'SUB CATEGORY',
                    value: selectedSubCategoryId.value,
                    disabled: selectedCategoryId.value == null,
                    items: subCategoryCtrl.subCategories
                        .map(
                          (sub) => DropdownMenuItem(
                            value: sub['id'].toString(),
                            child: Text(sub['name'].toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => selectedSubCategoryId.value = val,
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: nameCtrl,
          label: 'PRODUCT NAME',
          icon: Icons.shopping_bag_outlined,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: descCtrl,
          label: 'DESCRIPTION',
          icon: Icons.description_outlined,
          maxLines: 4,
        ),
        const SizedBox(height: 20),
        if (isMobile) ...[
          _buildTextField(
            controller: priceCtrl,
            label: 'PRICE (₹)',
            icon: Icons.payments_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: stockCtrl,
            label: 'STOCK',
            icon: Icons.inventory_2_outlined,
            keyboardType: TextInputType.number,
          ),
        ] else
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: NeoColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    bool disabled = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: disabled
            ? NeoColors.surface.withOpacity(0.5)
            : NeoColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: value,
          dropdownColor: NeoColors.surface,
          icon: const Icon(Icons.expand_more_rounded, color: NeoColors.textLow),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.oswald(
              color: NeoColors.textLow,
              fontSize: 11,
              letterSpacing: 1,
            ),
            border: InputBorder.none,
          ),
          items: items,
          onChanged: disabled ? null : onChanged,
          style: GoogleFonts.montserrat(
            color: NeoColors.textHigh,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitBtn() {
    return Obx(() {
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
          onPressed: productCtrl.isLoading.value ? null : _submitForm,
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
                  "LAUNCH PRODUCT",
                  style: GoogleFonts.oswald(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
        ),
      );
    });
  }

  void _submitForm() {
    if (selectedImages.isEmpty ||
        selectedCategoryId.value == null ||
        selectedSubCategoryId.value == null ||
        nameCtrl.text.isEmpty ||
        priceCtrl.text.isEmpty ||
        stockCtrl.text.isEmpty) {
      Get.snackbar(
        'ENTRY ERROR',
        'PLEASE COMPLE ALL FIELDS',
        backgroundColor: NeoColors.error.withOpacity(0.1),
        colorText: NeoColors.error,
      );
      return;
    }
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
    productCtrl.addProduct(
      name: nameCtrl.text.trim(),
      description: descCtrl.text.trim(),
      price: double.parse(priceCtrl.text.trim()),
      images: selectedImages,
      video: selectedVideo.value,
      categoryId: selectedCategoryId.value!,
      subCategoryId: selectedSubCategoryId.value!,
      stock: stock,
    );
  }
}
