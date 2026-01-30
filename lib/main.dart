import 'package:ecom/features/user/cart/controller/card_controller.dart';
import 'package:ecom/features/user/orders/controller/order_controller.dart';
import 'package:ecom/features/user/checkout/controller/checkout_controller.dart';
import 'package:ecom/features/user/home/controller/review_controller.dart';
import 'package:ecom/features/user/profile/controller/profile_controller.dart';
import 'package:ecom/features/user/wishlist/controller/wishlist_controller.dart';
import 'package:ecom/features/admin/products/controller/product_controller.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'core/config/supabase_config.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/controller/auth_controller.dart';

import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await SupabaseConfig.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: ColorConst.bg,
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme)
            .apply(
              bodyColor: ColorConst.textLight,
              displayColor: ColorConst.textLight,
            ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: ColorConst.primary,
          brightness: Brightness.dark,
          surface: ColorConst.card,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
        Get.put(CartController(), permanent: true);
        Get.put(ReviewController());
        Get.put(ProfileController());
        Get.put(CheckoutController(), permanent: true);
        Get.put(OrderController(), permanent: true);
        Get.put(WishlistController(), permanent: true);
        Get.put(AdminProductController(), permanent: true);
      }),
    );
  }
}
