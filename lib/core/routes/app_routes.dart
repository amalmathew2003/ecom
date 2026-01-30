import 'package:ecom/features/admin/products/ui/admin_home.dart';
import 'package:ecom/features/admin/products/ui/staff_dashboard.dart';
import 'package:ecom/features/auth/ui/login_page.dart';
import 'package:ecom/features/auth/ui/register_page.dart';
import 'package:ecom/features/delivery/ui/delivery_dashboard.dart';
import 'package:ecom/features/splash/controller/splash_controller.dart';
import 'package:ecom/features/splash/ui/splash_screen.dart';
import 'package:ecom/features/user/cart/ui/cart_screen.dart';
import 'package:ecom/features/user/home/ui/home/user_home.dart';
import 'package:ecom/features/user/nav/ui/buttom_nav.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const usernav = '/user-nav';
  static const userHome = '/user-home';
  static const userproductdetils = '/user-home/product-details';
  static const usercart = '/cart';
  static const adminHome = '/admin-home';
  static const staffHome = '/staff-home';
  static const deliveryHome = '/delivery-home';

  static final pages = [
    /// 🔹 Splash
    GetPage(
      name: splash,
      page: () => const SplashPage(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),

    /// 🔹 Login
    GetPage(
      name: login,
      page: () => LoginPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    /// 🔹 Register
    GetPage(
      name: register,
      page: () => RegisterPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    /// 🔹 User Home
    GetPage(name: usernav, page: () => const UserRootPage()),
    GetPage(name: userHome, page: () => UserHome()),
    GetPage(name: usercart, page: () => const CartScreen()),

    /// 🔹 Admin Console
    GetPage(name: adminHome, page: () => const AdminHome()),

    /// 🔹 Staff Portal
    GetPage(name: staffHome, page: () => const StaffDashboard()),

    /// 🔹 Delivery Portal
    GetPage(name: deliveryHome, page: () => const DeliveryDashboard()),
  ];
}
