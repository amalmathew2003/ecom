import 'package:ecom/features/admin/products/controller/category_add_controller.dart';
import 'package:ecom/features/admin/products/controller/sub_category_controller.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
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
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Manage Categories',
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ADD MAIN CATEGORY
            const Text(
              'New Main Category',
              style: TextStyle(
                color: ColorConst.textLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ColorConst.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ColorConst.surface, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: categoryNameCtrl,
                      style: const TextStyle(color: ColorConst.textLight),
                      decoration: const InputDecoration(
                        hintText: 'Category name (e.g. Footwear)',
                        hintStyle: TextStyle(color: ColorConst.textMuted),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  Obx(() {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: ColorConst.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        onPressed: categoryCtrl.isLoading.value
                            ? null
                            : () {
                                categoryCtrl.addCategory(categoryNameCtrl.text);
                                categoryNameCtrl.clear();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: categoryCtrl.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Add',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 32),

            /// MAIN CATEGORY LIST
            const Text(
              'Existing Main Categories',
              style: TextStyle(
                color: ColorConst.textLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: Obx(() {
                if (categoryCtrl.categories.isEmpty) {
                  return const Center(
                    child: Text(
                      "No categories found",
                      style: TextStyle(color: ColorConst.textMuted),
                    ),
                  );
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryCtrl.categories.length,
                  itemBuilder: (_, index) {
                    final cat = categoryCtrl.categories[index];
                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorConst.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ColorConst.surface,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cat['name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: ColorConst.textLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => categoryCtrl.deleteCategory(
                              cat['id'].toString(),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 32),

            /// SELECT CATEGORY FOR SUB-CATEGORY
            const Text(
              'Add Sub-Category',
              style: TextStyle(
                color: ColorConst.textLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: ColorConst.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ColorConst.surface, width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    dropdownColor: ColorConst.card,
                    initialValue: selectedCategoryId.value,
                    decoration: const InputDecoration(
                      labelText: 'Select Main Category',
                      labelStyle: TextStyle(color: ColorConst.textMuted),
                      border: InputBorder.none,
                    ),
                    items: categoryCtrl.categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['id'].toString(),
                        child: Text(
                          cat['name'],
                          style: const TextStyle(color: ColorConst.textLight),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      selectedCategoryId.value = val;
                      subCategoryCtrl.fetchSubCategories(val!);
                    },
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ColorConst.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ColorConst.surface, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: subCategoryNameCtrl,
                      style: const TextStyle(color: ColorConst.textLight),
                      decoration: const InputDecoration(
                        hintText: 'Sub-category name',
                        hintStyle: TextStyle(color: ColorConst.textMuted),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  Obx(() {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1),
                            const Color(0xFF818CF8).withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        onPressed:
                            (selectedCategoryId.value == null ||
                                subCategoryCtrl.isLoading.value)
                            ? null
                            : () {
                                subCategoryCtrl.addSubCategory(
                                  categoryId: selectedCategoryId.value!,
                                  name: subCategoryNameCtrl.text,
                                );
                                subCategoryNameCtrl.clear();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: subCategoryCtrl.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Add',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 32),

            /// SUB CATEGORY LIST
            const Text(
              'Existing Sub-Categories',
              style: TextStyle(
                color: ColorConst.textLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (subCategoryCtrl.subCategories.isEmpty) {
                  return Center(
                    child: Text(
                      selectedCategoryId.value == null
                          ? 'Select a category to see sub-categories'
                          : 'No sub-categories found',
                      style: const TextStyle(color: ColorConst.textMuted),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: subCategoryCtrl.subCategories.length,
                  itemBuilder: (_, index) {
                    final sub = subCategoryCtrl.subCategories[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: ColorConst.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ColorConst.surface, width: 1),
                      ),
                      child: ListTile(
                        title: Text(
                          sub['name'],
                          style: const TextStyle(
                            color: ColorConst.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ColorConst.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.subdirectory_arrow_right_rounded,
                            color: ColorConst.primary,
                            size: 20,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          onPressed: () => subCategoryCtrl.deleteSubCategory(
                            id: sub['id'].toString(),
                            categoryId: selectedCategoryId.value!,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
