import 'package:ecom/features/admin/ui/neo_admin_home.dart';
import 'package:ecom/features/auth/ui/neo_login_page.dart';
import 'package:ecom/features/auth/ui/neo_register_page.dart';
import 'package:ecom/features/landing/ui/neo_landing_screen.dart';
import 'package:ecom/features/splash/controller/splash_controller.dart';
import 'package:ecom/features/splash/ui/splash_screen.dart';
import 'package:ecom/features/user/cart/ui/cart_screen.dart';
import 'package:ecom/features/user/nav/ui/bottom_nav.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const splash = '/';
  static const landing = '/landing';
  static const login = '/login';
  static const register = '/register';
  static const usernav = '/user-nav';
  static const userHome = '/user-home';
  static const userproductdetils = '/user-home/product-details';
  static const usercart = '/cart';
  static const adminHome = '/admin';

  static final pages = [
    GetPage(
      name: splash,
      page: () => const SplashPage(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),
    GetPage(name: landing, page: () => const NeoLandingScreen()),
    GetPage(
      name: login,
      page: () => NeoLoginPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: register,
      page: () => NeoRegisterPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(name: usernav, page: () => const UserRootPage()),
    GetPage(name: usercart, page: () => const CartScreen()),
    GetPage(name: adminHome, page: () => const NeoAdminHome()),
  ];
}
