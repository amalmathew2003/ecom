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
          child: KeyedSubtree(
            key: ValueKey(nav.currentIndex.value),
            child: pages[nav.currentIndex.value],
          ),
        ),

        /// BOTTOM NAVIGATION
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: ColorConst.card.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: ColorConst.surface.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.grid_view_rounded, 'Home', nav),
                _buildNavItem(1, Icons.shopping_bag_rounded, 'Cart', nav),
                _buildNavItem(2, Icons.person_rounded, 'Profile', nav),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    UserNavController nav,
  ) {
    final isActive = nav.currentIndex.value == index;
    return GestureDetector(
      onTap: () => nav.changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? ColorConst.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? ColorConst.primary : ColorConst.textMuted,
              size: 26,
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 4,
                width: 4,
                decoration: const BoxDecoration(
                  color: ColorConst.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
