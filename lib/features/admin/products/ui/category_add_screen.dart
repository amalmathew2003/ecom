import 'package:ecom/features/admin/products/controller/category_add_controller.dart';
import 'package:ecom/features/admin/products/controller/sub_category_controller.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:ecom/core/utils/responsive_layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminAddCategoryPage extends StatelessWidget {
  AdminAddCategoryPage({super.key});

  final categoryCtrl = Get.put(AdminCategoryController());
  final subCategoryCtrl = Get.put(AdminSubCategoryController());

  final TextEditingController categoryNameCtrl = TextEditingController();
  final TextEditingController subCategoryNameCtrl = TextEditingController();

  final RxnString selectedCategoryId = RxnString();

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
                    _sectionTitle("MASTER CLASSIFICATION"),
                    const SizedBox(height: 15),
                    _buildAddMainCategory(),
                    const SizedBox(height: 30),
                    _buildMainCategoryList(),
                    const SizedBox(height: 50),
                    _sectionTitle("SUB-LOGISTICS"),
                    const SizedBox(height: 15),
                    _buildAddSubCategory(),
                    const SizedBox(height: 30),
                    _buildSubCategoryList(),
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
            "CLASSIFICATION",
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

  Widget _buildAddMainCategory() {
    return Container(
      decoration: BoxDecoration(
        color: NeoColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: categoryNameCtrl,
              style: GoogleFonts.montserrat(
                color: NeoColors.textHigh,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'IDENTIFIER (E.G. FOOTWEAR)',
                hintStyle: GoogleFonts.oswald(
                  color: NeoColors.textLow,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
              ),
            ),
          ),
          Obx(
            () => Container(
              margin: const EdgeInsets.only(right: 8),
              height: 54,
              width: 100,
              decoration: BoxDecoration(
                gradient: NeoColors.premiumGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: categoryCtrl.isLoading.value
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: () {
                        if (categoryNameCtrl.text.isNotEmpty) {
                          categoryCtrl.addCategory(
                            categoryNameCtrl.text.toUpperCase(),
                          );
                          categoryNameCtrl.clear();
                        }
                      },
                      child: Text(
                        "ADD",
                        style: GoogleFonts.oswald(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCategoryList() {
    return SizedBox(
      height: 140,
      child: Obx(() {
        if (categoryCtrl.categories.isEmpty)
          return Center(
            child: Text(
              "NO MASTER CLASSES FOUND",
              style: GoogleFonts.oswald(color: NeoColors.textLow, fontSize: 12),
            ),
          );
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categoryCtrl.categories.length,
          itemBuilder: (_, index) {
            final cat = categoryCtrl.categories[index];
            return Container(
              width: 180,
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: NeoColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cat['name'].toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.oswald(
                      color: NeoColors.textHigh,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 15),
                  IconButton(
                    onPressed: () =>
                        categoryCtrl.deleteCategory(cat['id'].toString()),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: NeoColors.error,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: NeoColors.error.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildAddSubCategory() {
    return Column(
      children: [
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: NeoColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                value: selectedCategoryId.value,
                dropdownColor: NeoColors.surface,
                icon: const Icon(
                  Icons.expand_more_rounded,
                  color: NeoColors.textLow,
                ),
                decoration: InputDecoration(
                  labelText: 'MASTER CATEGORY',
                  labelStyle: GoogleFonts.oswald(
                    color: NeoColors.textLow,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                  border: InputBorder.none,
                ),
                items: categoryCtrl.categories
                    .map(
                      (cat) => DropdownMenuItem<String>(
                        value: cat['id'].toString(),
                        child: Text(
                          cat['name'].toUpperCase(),
                          style: GoogleFonts.montserrat(
                            color: NeoColors.textHigh,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  selectedCategoryId.value = val;
                  subCategoryCtrl.fetchSubCategories(val!);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: NeoColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: subCategoryNameCtrl,
                  style: GoogleFonts.montserrat(
                    color: NeoColors.textHigh,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'SUB-IDENTIFIER',
                    hintStyle: GoogleFonts.oswald(
                      color: NeoColors.textLow,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                  ),
                ),
              ),
              Obx(
                () => Container(
                  margin: const EdgeInsets.only(right: 8),
                  height: 54,
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: NeoColors.premiumGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:
                      (selectedCategoryId.value == null ||
                          subCategoryCtrl.isLoading.value)
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : TextButton(
                          onPressed: () {
                            if (subCategoryNameCtrl.text.isNotEmpty) {
                              subCategoryCtrl.addSubCategory(
                                categoryId: selectedCategoryId.value!,
                                name: subCategoryNameCtrl.text.toUpperCase(),
                              );
                              subCategoryNameCtrl.clear();
                            }
                          },
                          child: Text(
                            "ADD",
                            style: GoogleFonts.oswald(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategoryList() {
    return Obx(() {
      if (subCategoryCtrl.subCategories.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: NeoColors.surface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              selectedCategoryId.value == null
                  ? "SELECT MASTER CLASS FIRST"
                  : "NO SUB-CLASSES DEFINED",
              style: GoogleFonts.oswald(
                color: NeoColors.textLow,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: subCategoryCtrl.subCategories.length,
        itemBuilder: (_, index) {
          final sub = subCategoryCtrl.subCategories[index];
          return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: NeoColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.03)),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: NeoColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.subdirectory_arrow_right_rounded,
                      color: NeoColors.accent,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    sub['name'].toUpperCase(),
                    style: GoogleFonts.oswald(
                      color: NeoColors.textHigh,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () => subCategoryCtrl.deleteSubCategory(
                      id: sub['id'].toString(),
                      categoryId: selectedCategoryId.value!,
                    ),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: NeoColors.error,
                      size: 18,
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: Duration(milliseconds: index * 50))
              .slideY(begin: 0.1);
        },
      );
    });
  }
}
