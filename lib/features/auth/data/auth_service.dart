import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> login(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> register(String email, String password) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (res.user == null) {
      throw Exception('Signup failed');
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
