import 'package:ecom/core/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashController extends GetxController {
  final supabase = Supabase.instance.client;
  bool _navigated = false;

  @override
  void onReady() {
    super.onReady();
    _startFlow();
  }

  Future<void> _startFlow() async {
    try {
      // ✅ Force splash visibility for branding
      await Future.delayed(const Duration(seconds: 2));

      if (_navigated) return;

      final session = supabase.auth.currentSession;

      if (session == null) {
        _navigateTo(AppRoutes.login);
        return;
      }

      // Fetch user role to decide which panel to show
      final response = await supabase
          .from('profiles')
          .select('role')
          .eq('id', session.user.id)
          .maybeSingle();

      if (response == null) {
        // Session exists but no profile? Likely a partially completed registration or deleted user.
        // Sign out to clean up state and go to login.
        await supabase.auth.signOut();
        _navigateTo(AppRoutes.login);
        return;
      }

      if (response['role'] == 'admin') {
        _navigateTo(AppRoutes.adminHome);
      } else if (response['role'] == 'staff') {
        _navigateTo(AppRoutes.staffHome);
      } else {
        _navigateTo(AppRoutes.usernav);
      }
    } catch (e) {
      print("Splash Error: $e");
      // On error, fallback to login to be safe
      _navigateTo(AppRoutes.login);
    }
  }

  void _navigateTo(String route) {
    if (_navigated) return;
    _navigated = true;
    Get.offAllNamed(route);
  }
}
