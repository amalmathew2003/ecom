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
    // ✅ Force splash visibility
    await Future.delayed(const Duration(seconds: 2));

    if (_navigated) return;
    _navigated = true;

    final session = supabase.auth.currentSession;

    if (session == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    final profile = await supabase
        .from('profiles')
        .select('role')
        .eq('id', session.user.id)
        .maybeSingle();

    if (profile?['role'] == 'admin') {
      Get.offAllNamed(AppRoutes.adminHome);
    } else {
      Get.offAllNamed(AppRoutes.usernav);
    }
  }
}
