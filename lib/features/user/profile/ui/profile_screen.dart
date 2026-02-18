import 'package:ecom/features/user/orders/ui/order_screen.dart';
import 'package:ecom/features/user/wishlist/ui/wishlist_screen.dart';
import 'package:ecom/features/user/profile/controller/profile_controller.dart';
import 'package:ecom/features/auth/controller/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecom/core/routes/app_routes.dart';

import 'package:ecom/core/theme/neo_colors.dart';
import 'package:ecom/core/utils/responsive_layout.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom/features/user/profile/ui/edit_profile_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: NeoColors.background,
      body: Stack(
        children: [
          // 1. Kinetic Background
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          // 2. Ambient Orbs
          Positioned(
            top: -100,
            left: -100,
            child: _FloatingOrb(NeoColors.accent.withOpacity(0.1), 400),
          ),
          Positioned(
            bottom: 100,
            right: -50,
            child: _FloatingOrb(Colors.purpleAccent.withOpacity(0.05), 300),
          ),

          // 3. Content
          ResponsiveLayout(
            child: user == null
                ? _buildGuestState(context)
                : _buildProfileContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 60,
            color: NeoColors.textLow.withOpacity(0.5),
          ),
          const SizedBox(height: 30),
          Text(
            "RESTRICTED AREA",
            style: GoogleFonts.oswald(
              color: NeoColors.textHigh,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ).animate().fadeIn().moveY(begin: 20),
          const SizedBox(height: 40),
          _actionButton("LOGIN", () => Get.toNamed(AppRoutes.login)),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    final profileCtrl = Get.find<ProfileController>();
    final authCtrl = Get.find<AuthController>();

    return Obx(() {
      final profile = profileCtrl.profile.value;
      if (profile == null) {
        return const Center(
          child: CircularProgressIndicator(color: NeoColors.accent),
        );
      }

      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAvatarSection(profile),
              const SizedBox(height: 50),
              _menuItem(
                "ORDERS",
                Icons.history_edu_rounded,
                () => Get.to(() => const OrderScreen()),
              ),
              _menuItem(
                "WISHLIST",
                Icons.bookmark_border_rounded,
                () => Get.to(() => const WishlistScreen()),
              ),
              _menuItem(
                "SAVED ADDRESSES",
                Icons.map_outlined,
                () => Get.to(() => const EditProfileScreen()),
              ),
              const SizedBox(height: 40),
              _actionButton(
                "LOGOUT",
                () async => await authCtrl.logout(),
                isDestructive: true,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAvatarSection(profile) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: NeoColors.accent, width: 2),
            color: NeoColors.background,
            boxShadow: [
              BoxShadow(
                color: NeoColors.accent.withOpacity(0.2),
                blurRadius: 50,
              ),
            ],
          ),
          child: Center(
            child: Text(
              profile.fullName.isNotEmpty
                  ? profile.fullName[0].toUpperCase()
                  : "U",
              style: GoogleFonts.oswald(
                color: NeoColors.accent,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ).animate().scale(),
        const SizedBox(height: 20),
        Text(
          profile.fullName.toUpperCase(),
          style: GoogleFonts.oswald(
            color: NeoColors.textHigh,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        Text(
          profile.email,
          style: GoogleFonts.montserrat(
            color: NeoColors.textLow,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _menuItem(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          color: Colors.white.withOpacity(0.02),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.oswald(
                color: NeoColors.textHigh,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Icon(icon, color: NeoColors.textLow, size: 20),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _actionButton(
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDestructive
              ? NeoColors.error.withOpacity(0.1)
              : NeoColors.accent,
          border: isDestructive ? Border.all(color: NeoColors.error) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.oswald(
              color: isDestructive ? NeoColors.error : NeoColors.background,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    const spacing = 40.0;

    for (var i = 0.0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (var i = 0.0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FloatingOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _FloatingOrb(this.color, this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color, blurRadius: 100, spreadRadius: 20),
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.1, 1.1),
          duration: const Duration(seconds: 4),
        );
  }
}
