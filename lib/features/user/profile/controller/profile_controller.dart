import 'package:ecom/features/user/profile/data/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends GetxController {
  final supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final profile = Rxn<ProfileModel>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      isLoading.value = true;

      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        profile.value = ProfileModel.fromJson(data);
      }
    } catch (e) {
      Get.log("Profile Fetch Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      isLoading.value = true;

      final updates = <String, dynamic>{};
      if (name != null) updates['full_name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;

      if (updates.isEmpty) return;

      await supabase.from('profiles').update(updates).eq('id', user.id);
      await fetchProfile(); // Refresh local data

      Get.snackbar(
        "Success",
        "Profile updated successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.log("Profile Update Error: $e");
      Get.snackbar(
        "Error",
        "Failed to update profile",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearProfile() {
    profile.value = null;
  }
}
