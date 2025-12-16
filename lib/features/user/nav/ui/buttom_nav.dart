import 'package:ecom/features/user/cart/ui/cart_screen.dart';
import 'package:ecom/features/user/home/ui/user_home.dart';
import 'package:ecom/features/user/nav/controller/nav_controller.dart';
import 'package:ecom/features/user/product/ui/product_screen.dart';
import 'package:ecom/features/user/profile/ui/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserRootPage extends StatelessWidget {
  const UserRootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.put(UserNavController());

    final pages = [
      UserHome(),
      const ProductScreen(),
      const CartScreen(),
      const SerachScreen(),
    ];

    return Obx(
      () => Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: pages[nav.currentIndex.value],
        ),

        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 10,
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: nav.currentIndex.value,
            onTap: nav.changeTab,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,

            items: [
              _navItem(Icons.home_rounded, 'Home', nav.currentIndex.value == 0),
              _navItem(Icons.search, 'Search', nav.currentIndex.value == 1),
              _navItem(
                Icons.shopping_cart_outlined,
                'Cart',
                nav.currentIndex.value == 2,
              ),
              _navItem(
                Icons.person_outline,
                'Profile',
                nav.currentIndex.value == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem(IconData icon, String label, bool isActive) {
    return BottomNavigationBarItem(
      label: label,
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.black.withValues(alpha: .08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon),
      ),
    );
  }
}
