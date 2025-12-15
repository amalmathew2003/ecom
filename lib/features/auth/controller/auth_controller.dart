import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
        Get.offAllNamed(AppRoutes.userHome);
      }
    } catch (e) {
      Get.snackbar('Login Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // 🔹 REGISTER
  Future<void> register(String email, String password) async {
    try {
      isLoading.value = true;

      await _service.register(email, password);

      // New users are always normal users
      Get.offAllNamed(AppRoutes.userHome);
    } catch (e) {
      Get.snackbar('Registration Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // 🔹 LOGOUT
  Future<void> logout() async {
    await _service.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}
