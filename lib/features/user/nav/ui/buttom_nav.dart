import 'package:ecom/features/user/cart/ui/cart_screen.dart';
import 'package:ecom/features/user/home/ui/home/user_home.dart';
import 'package:ecom/features/user/nav/controller/nav_controller.dart';
import 'package:ecom/features/user/profile/ui/profile_screen.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserRootPage extends StatelessWidget {
  const UserRootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.put(UserNavController());

    final pages = [UserHome(), CartScreen(), const ProfileScreen()];

    return Obx(
      () => Scaffold(
        backgroundColor: ColorConst.bg,
        extendBody: true,

        /// MAIN BODY
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: pages[nav.currentIndex.value],
        ),

        /// BOTTOM NAVIGATION
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Container(
              decoration: BoxDecoration(
                color: ColorConst.card,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                currentIndex: nav.currentIndex.value,
                onTap: nav.changeTab,
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                showUnselectedLabels: true,

                selectedItemColor: ColorConst.accent,
                unselectedItemColor: ColorConst.textMuted.withOpacity(0.7),

                items: [
                  _navItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isActive: nav.currentIndex.value == 0,
                  ),
                  _navItem(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Cart',
                    isActive: nav.currentIndex.value == 1,
                  ),
                  _navItem(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    isActive: nav.currentIndex.value == 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// NAV ITEM (UI ONLY)
  BottomNavigationBarItem _navItem({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return BottomNavigationBarItem(
      label: label,
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? ColorConst.accent.withOpacity(0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 22),
      ),
    );
  }
}
