import 'package:ecom/features/user/cart/ui/cart_screen.dart';
import 'package:ecom/features/user/home/ui/home/user_home.dart';
import 'package:ecom/features/user/nav/controller/nav_controller.dart';
import 'package:ecom/features/user/profile/ui/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserRootPage extends StatelessWidget {
  const UserRootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.put(UserNavController());

    final pages = [UserHome(), const CartScreen(), const ProfileScreen()];

    const navy = Color(0xFF0B1A3A);
    const ivory = Color(0xFFF6E3B5);

    return Obx(
      () => Scaffold(
        extendBody: true,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: pages[nav.currentIndex.value],
        ),

        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12), // space around nav
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24), // ✅ CURVE HERE
            child: Container(
              decoration: BoxDecoration(
                color: navy,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                backgroundColor: navy,
                currentIndex: nav.currentIndex.value,
                onTap: nav.changeTab,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: ivory,
                unselectedItemColor: ivory.withValues(alpha: .6),
                showUnselectedLabels: true,
                elevation: 0,
                items: [
                  _navItem(
                    Icons.home_rounded,
                    'Home',
                    nav.currentIndex.value == 0,
                  ),
                  _navItem(
                    Icons.shopping_cart_outlined,
                    'Cart',
                    nav.currentIndex.value == 1,
                  ),
                  _navItem(
                    Icons.person_outline,
                    'Profile',
                    nav.currentIndex.value == 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem(IconData icon, String label, bool isActive) {
    const ivory = Color(0xFFF6E3B5);

    return BottomNavigationBarItem(
      label: label,
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? ivory.withValues(alpha: .15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon),
      ),
    );
  }
}
