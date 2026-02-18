import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import '../data/auth_service.dart';

import '../../../core/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _service = AuthService();
  final SupabaseClient _client = Supabase.instance.client;

  final isLoading = false.obs;

  // 🔹 LOGIN
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      await _service.login(email, password);

      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('Login failed');
      }

      final profile = await _client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (profile?['role'] == 'admin') {
        Get.offAllNamed(AppRoutes.adminHome);
      } else {
        Get.offAllNamed(AppRoutes.usernav);
      }
    } catch (e) {
      final message = e is AuthException
          ? e.message
          : e.toString().replaceAll('Exception:', '').trim();
      Get.snackbar(
        'Login Failed',
        "$message\ncheck your credentials and try again.",
        backgroundColor: NeoColors.surface,
        colorText: NeoColors.textHigh,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 20,
        boxShadows: [
          BoxShadow(
            color: NeoColors.accent.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        icon: const Icon(Icons.error_outline_rounded, color: NeoColors.error),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 🔹 REGISTER
  Future<void> register(String email, String password, name) async {
    try {
      isLoading.value = true;

      await _service.register(email, password, name);

      // New users are always normal users
      Get.offAllNamed(AppRoutes.usernav);
    } catch (e) {
      final message = e is AuthException
          ? e.message
          : e.toString().replaceAll('Exception:', '').trim();
      Get.snackbar(
        'Registration Failed',
        "$message\nplease try again.",
        backgroundColor: NeoColors.surface,
        colorText: NeoColors.textHigh,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(26),
        borderRadius: 20,
        boxShadows: [
          BoxShadow(
            color: NeoColors.accent.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        icon: const Icon(Icons.error_outline_rounded, color: NeoColors.error),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 🔹 LOGOUT
  Future<void> logout() async {
    await _service.logout();
    Get.offAllNamed(AppRoutes.landing);
  }
}
