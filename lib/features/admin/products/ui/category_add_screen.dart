import 'package:ecom/features/admin/products/controller/category_add_controller.dart';
import 'package:ecom/features/admin/products/controller/sub_category_controller.dart';
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
      appBar: AppBar(title: const Text('Manage Categories')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// =======================
            /// ADD MAIN CATEGORY
            /// =======================
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: categoryNameCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Main category name',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Obx(() {
                  return ElevatedButton(
                    onPressed: categoryCtrl.isLoading.value
                        ? null
                        : () {
                            categoryCtrl.addCategory(categoryNameCtrl.text);
                            categoryNameCtrl.clear();
                          },
                    child: categoryCtrl.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text('Add'),
                  );
                }),
              ],
            ),

            const SizedBox(height: 24),

            /// =======================
            /// SELECT CATEGORY
            /// =======================
            Obx(() {
              if (categoryCtrl.categories.isEmpty) {
                return const Text('No categories yet');
              }

              return DropdownButtonFormField<String>(
                value: selectedCategoryId.value,
                decoration: const InputDecoration(
                  labelText: 'Select Main Category',
                ),
                items: categoryCtrl.categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat['id'].toString(), // ✅ FIX
                    child: Text(cat['name']),
                  );
                }).toList(),
                onChanged: (val) {
                  selectedCategoryId.value = val;
                  subCategoryCtrl.fetchSubCategories(val!);
                },
              );
            }),

            const SizedBox(height: 16),

            /// =======================
            /// ADD SUB CATEGORY
            /// =======================
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: subCategoryNameCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Sub-category name',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Obx(() {
                  return ElevatedButton(
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
                    child: subCategoryCtrl.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text('Add'),
                  );
                }),
              ],
            ),

            const SizedBox(height: 20),

            /// =======================
            /// SUB CATEGORY LIST
            /// =======================
            Expanded(
              child: Obx(() {
                if (subCategoryCtrl.subCategories.isEmpty) {
                  return const Center(child: Text('No sub-categories found'));
                }

                return ListView.builder(
                  itemCount: subCategoryCtrl.subCategories.length,
                  itemBuilder: (_, index) {
                    final sub = subCategoryCtrl.subCategories[index];
                    return ListTile(
                      title: Text(sub['name']),
                      leading: const Icon(Icons.subdirectory_arrow_right),
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
