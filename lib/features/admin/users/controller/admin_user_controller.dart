import 'package:ecom/features/user/profile/data/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUserController extends GetxController {
  final supabase = Supabase.instance.client;

  final users = <ProfileModel>[].obs;
  final isLoading = false.obs;

  // Stats
  final totalUsers = 0.obs;
  final adminCount = 0.obs;
  final staffCount = 0.obs;

  // Filter & Search
  final filterRole = 'all'.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('profiles')
          .select()
          .order('full_name');

      final allFetched = (response as List)
          .map((e) => ProfileModel.fromJson(e))
          .toList();

      // 🚀 EXCLUDE ADMINS FROM MANAGEMENT LIST
      final nonAdmins = allFetched
          .where((u) => u.role.trim().toLowerCase() != 'admin')
          .toList();
      users.assignAll(nonAdmins);

      // Update Stats
      totalUsers.value = users.length;
      adminCount.value = allFetched
          .where((u) => u.role.trim().toLowerCase() == 'admin')
          .length;
      staffCount.value = allFetched
          .where((u) => u.role.trim().toLowerCase() == 'staff')
          .length;

      // 💡 RLS HINT: If DB only returns the current user, they need to update Supabase RLS policies.
      if (allFetched.length == 1 && nonAdmins.isEmpty) {
        Future.delayed(const Duration(seconds: 1), () {
          Get.snackbar(
            'Security Policy Info',
            'Database returned only 1 user (you). Please allow admins to select all profiles in your Supabase RLS settings.',
            duration: const Duration(seconds: 8),
            backgroundColor: const Color(0xFF1E293B),
            colorText: Colors.white,
            icon: const Icon(Icons.security, color: Colors.orangeAccent),
          );
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<ProfileModel> get filteredUsers {
    List<ProfileModel> baseList = users;

    // Role Filter (Displaying Staff or User)
    if (filterRole.value != 'all') {
      baseList = baseList
          .where(
            (u) =>
                u.role.trim().toLowerCase() == filterRole.value.toLowerCase(),
          )
          .toList();
    }

    // Search Filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.trim().toLowerCase();
      baseList = baseList
          .where(
            (u) =>
                u.fullName.toLowerCase().contains(query) ||
                u.email.toLowerCase().contains(query) ||
                u.phone.contains(query),
          )
          .toList();
    }

    return baseList;
  }

  Future<void> updateRole(String userId, String newRole) async {
    try {
      await supabase
          .from('profiles')
          .update({'role': newRole})
          .eq('id', userId);
      await fetchUsers();
      Get.snackbar('Success', 'User role updated to $newRole');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update role');
    }
  }

  Future<void> registerStaffMember({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      isLoading.value = true;

      // 1. Create User in Auth
      final res = await supabase.auth.signUp(email: email, password: password);

      if (res.user == null) throw Exception("Failed to create user account");

      // 2. Create Profile with 'staff' role
      await supabase.from('profiles').upsert({
        'id': res.user!.id,
        'email': email,
        'full_name': name,
        'role': 'staff',
      });

      await fetchUsers();
      Get.snackbar('Success', 'Staff member registered successfully');
    } catch (e) {
      Get.snackbar('Registration Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
