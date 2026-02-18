import 'package:ecom/features/shop/ui/neo_search_screen.dart';
import 'package:ecom/features/user/cart/ui/cart_screen.dart';
import 'package:ecom/features/shop/ui/neo_shop_screen.dart';
import 'package:ecom/features/user/nav/controller/nav_controller.dart';
import 'package:ecom/features/user/profile/ui/profile_screen.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:ecom/core/utils/responsive_layout.dart';
import 'package:ecom/features/auth/ui/neo_login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';

class UserRootPage extends StatelessWidget {
  const UserRootPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Put the controller if not already present
    final nav = Get.put(UserNavController());

    // Check Authentication State
    final user = Supabase.instance.client.auth.currentUser;

    // Define pages dynamically based on auth state
    final pages = [
      const NeoShopScreen(),
      user != null ? const CartScreen() : NeoLoginPage(),
      user != null ? const ProfileScreen() : NeoLoginPage(),
    ];

    // If navigating to a restricted page while logged out, reset to home to avoid confusion
    // or keep them on the login page? The requested behavior is to "remove" the tabs.
    // So if the user is not logged in, they physically can't click the tabs.

    return Obx(() {
      final isMobile = ResponsiveLayout.isMobile(context);

      return Scaffold(
        backgroundColor: NeoColors.background,
        extendBody: true, // Key for floating nav
        // Web Nav
        appBar: isMobile ? null : _buildWebNavBar(nav, user != null),
        // Page Content
        body: IndexedStack(index: nav.currentIndex.value, children: pages),
        // Mobile Nav
        bottomNavigationBar: isMobile
            ? _buildBottomNav(nav, user != null)
            : null,
      );
    });
  }

  PreferredSizeWidget _buildWebNavBar(
    UserNavController nav,
    bool isAuthenticated,
  ) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            decoration: BoxDecoration(
              color: NeoColors.background.withOpacity(0.8),
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
            ),
            child: Row(
              children: [
                Text(
                  "NEO.STORE",
                  style: GoogleFonts.oswald(
                    color: NeoColors.textHigh,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 24,
                  ),
                ),
                const Spacer(),
                _webNavItem("HOME", 0, nav),
                if (isAuthenticated) ...[
                  const SizedBox(width: 40),
                  _webNavItem("CART", 1, nav),
                  const SizedBox(width: 40),
                  _webNavItem("ACCOUNT", 2, nav),
                ] else ...[
                  const SizedBox(width: 40),
                  _loginButton(),
                ],
                const SizedBox(width: 60),
                IconButton(
                  onPressed: () => Get.to(() => NeoSearchScreen()),
                  icon: const Icon(
                    Icons.search_rounded,
                    color: NeoColors.textHigh,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _webNavItem(String label, int index, UserNavController nav) {
    return Obx(() {
      final isActive = nav.currentIndex.value == index;
      return InkWell(
        onTap: () => nav.changeTab(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.oswald(
                color: isActive ? NeoColors.textHigh : NeoColors.textMedium,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 20 : 0,
              height: 2,
              color: NeoColors.accent,
            ),
          ],
        ),
      );
    });
  }

  Widget _loginButton() {
    return InkWell(
      onTap: () => Get.to(() => NeoLoginPage()),
      child: Text(
        "LOGIN",
        style: GoogleFonts.oswald(
          color: NeoColors.accent,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildBottomNav(UserNavController nav, bool isAuthenticated) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: isAuthenticated
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _navItem(nav, 0, Icons.grid_view_rounded),
                      _navItem(nav, 1, Icons.shopping_bag_outlined),
                      _navItem(nav, 2, Icons.person_outline_rounded),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _navItem(nav, 0, Icons.grid_view_rounded),
                      GestureDetector(
                        onTap: () => Get.to(() => NeoLoginPage()),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: NeoColors.accent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.login_rounded,
                            color: NeoColors.accent,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(UserNavController nav, int index, IconData icon) {
    return Obx(() {
      final isActive = nav.currentIndex.value == index;
      return GestureDetector(
        onTap: () => nav.changeTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive
                ? NeoColors.accent.withOpacity(0.2)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? NeoColors.accent : NeoColors.textLow,
            size: 24,
          ),
        ),
      );
    });
  }
}
