import 'package:ecom/features/user/profile/controller/profile_controller.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final profileCtrl = Get.find<ProfileController>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = profileCtrl.profile.value;
    if (profile != null) {
      nameCtrl.text = profile.fullName;
      phoneCtrl.text = profile.phone;
      addressCtrl.text = profile.address;
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
          'Edit Profile',
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
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTextField(
              controller: nameCtrl,
              label: "Full Name",
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: phoneCtrl,
              label: "Phone Number",
              icon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: addressCtrl,
              label: "Delivery Address",
              icon: Icons.location_on_outlined,
              maxLines: 4,
            ),
            const SizedBox(height: 40),
            Obx(() {
              return SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: profileCtrl.isLoading.value
                      ? null
                      : () async {
                          if (nameCtrl.text.isEmpty ||
                              phoneCtrl.text.isEmpty ||
                              addressCtrl.text.isEmpty) {
                            Get.snackbar(
                              "Error",
                              "All fields are required",
                              colorText: Colors.white,
                              backgroundColor: Colors.redAccent,
                            );
                            return;
                          }

                          await profileCtrl.updateProfile(
                            name: nameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            address: addressCtrl.text.trim(),
                          );
                          Get.back();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConst.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: profileCtrl.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Save Changes",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
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
        border: Border.all(color: ColorConst.surface.withValues(alpha: 0.5)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: ColorConst.textLight,
          fontWeight: FontWeight.w500,
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: ColorConst.textMuted),
          prefixIcon: Icon(icon, color: ColorConst.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
