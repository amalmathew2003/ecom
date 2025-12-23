import 'package:ecom/features/user/cart/controller/card_controller.dart';
import 'package:ecom/features/user/home/controller/review_controller.dart';
import 'package:ecom/features/user/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/config/supabase_config.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/controller/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,

      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
        Get.put(CartController(), permanent: true);
        Get.put(ReviewController());
        Get.put(ProfileController());
      }),
    );
  }
}
