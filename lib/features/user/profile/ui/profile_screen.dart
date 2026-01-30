import 'package:animate_do/animate_do.dart';
import 'package:ecom/features/user/orders/ui/order_screen.dart';
import 'package:ecom/features/user/wishlist/ui/wishlist_screen.dart';
import 'package:ecom/features/user/profile/controller/profile_controller.dart';
import 'package:ecom/features/auth/controller/auth_controller.dart';
import 'package:ecom/core/routes/app_routes.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom/features/user/profile/ui/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.find<ProfileController>();
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: ColorConst.bg,
      body: Obx(() {
        final profile = profileCtrl.profile.value;

        if (profile == null) {
          return const Center(
            child: CircularProgressIndicator(color: ColorConst.primary),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              /// 🎭 HERO HEADER
              _buildModernHeader(profile),

              const SizedBox(height: 30),

              /// 📦 ACCOUNT SECTIONS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInLeft(
                      child: const Text(
                        "My Activity",
                        style: TextStyle(
                          color: ColorConst.textLight,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _profileCard(
                      icon: Icons.shopping_bag_rounded,
                      title: "My Orders",
                      subtitle: "View history & track packages",
                      color: ColorConst.primary,
                      onTap: () => Get.to(() => const OrderScreen()),
                    ),
                    _profileCard(
                      icon: Icons.favorite_rounded,
                      title: "Wishlist",
                      subtitle: "Your favorite items saved",
                      color: Colors.pinkAccent,
                      onTap: () => Get.to(() => const WishlistScreen()),
                    ),

                    const SizedBox(height: 32),
                    FadeInLeft(
                      delay: const Duration(milliseconds: 200),
                      child: const Text(
                        "Settings",
                        style: TextStyle(
                          color: ColorConst.textLight,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _profileCard(
                      icon: Icons.location_on_rounded,
                      title: "Addresses",
                      subtitle: profile.address.isNotEmpty
                          ? profile.address
                          : "Add your shipping address",
                      color: Colors.blueAccent,
                      onTap: () => Get.to(() => const EditProfileScreen()),
                    ),
                    _profileCard(
                      icon: Icons.security_rounded,
                      title: "Security",
                      subtitle: "Change password & sessions",
                      color: Colors.tealAccent,
                      onTap: () {},
                    ),

                    const SizedBox(height: 40),

                    /// 🚪 LOGOUT BUTTON
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await authCtrl.logout();
                            Get.offAllNamed(AppRoutes.login);
                          },
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: ColorConst.danger,
                          ),
                          label: const Text(
                            "Sign Out",
                            style: TextStyle(
                              color: ColorConst.danger,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: ColorConst.danger,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 120), // Buffer for nav bar
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildModernHeader(profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
      decoration: BoxDecoration(
        color: ColorConst.card,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: ColorConst.primaryGradient,
                  border: Border.all(color: ColorConst.surface, width: 4),
                ),
                child: Center(
                  child: Text(
                    profile.fullName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => Get.to(() => const EditProfileScreen()),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: ColorConst.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            profile.fullName,
            style: const TextStyle(
              color: ColorConst.textLight,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: ColorConst.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              profile.email,
              style: const TextStyle(
                color: ColorConst.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ColorConst.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorConst.surface.withValues(alpha: 0.6)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: ColorConst.textLight,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: ColorConst.textMuted, fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorConst.bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: ColorConst.textMuted,
            size: 12,
          ),
        ),
      ),
    );
  }
}
