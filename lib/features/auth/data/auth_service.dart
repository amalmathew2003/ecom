import 'package:ecom/core/supabase/supabase_client.dart';
import 'package:ecom/features/user/profile/controller/profile_controller.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> login(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
    Get.find<ProfileController>().fetchProfile();
  }

  Future<void> register(String email, String password, String name) async {
    final res = await _client.auth.signUp(email: email, password: password);

    final user = res.user;
    if (user == null) {
      throw Exception('Signup failed');
    }

    // ✅ CREATE profile row properly
    await supabase.from('profiles').upsert({
      'id': user.id,
      'email': email,
      'full_name': name,
      'role': 'user',
    });

    // 🚀 SYNC Profile state
    Get.find<ProfileController>().fetchProfile();
  }

  Future<void> logout() async {
    await _client.auth.signOut();
    Get.find<ProfileController>().clearProfile();
  }
}
