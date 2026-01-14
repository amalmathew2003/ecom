import 'package:ecom/features/user/orders/ui/oder_screen.dart';
import 'package:ecom/features/user/profile/controller/profile_controller.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: ColorConst.bg,
      body: SafeArea(
        child: Obx(() {
          final profile = profileCtrl.profile.value;

          if (profile == null) {
            return const Center(
              child: CircularProgressIndicator(color: ColorConst.accent),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// ================= HEADER =================
              Row(
                children: [
                  const BackButton(color: ColorConst.textLight),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    color: ColorConst.textLight,
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// ================= PROFILE CARD =================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ColorConst.card,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .4),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    /// AVATAR
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: ColorConst.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: ColorConst.accent, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          profile.fullName.isNotEmpty
                              ? profile.fullName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: ColorConst.accent,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    /// INFO
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.fullName,
                            style: const TextStyle(
                              color: ColorConst.textLight,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            profile.email,
                            style: const TextStyle(color: ColorConst.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// ================= SECTION TITLE =================
              const Text(
                "Account",
                style: TextStyle(
                  color: ColorConst.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              /// ================= ACTION GRID =================
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                children: [
                  _ActionTile(
                    icon: Icons.shopping_bag_outlined,
                    title: "My Orders",
                    onTap: () {
                      Get.to(() => const OrderScreen());
                    },
                  ),
                  _ActionTile(
                    icon: Icons.person_outline,
                    title: "Edit Profile",
                    onTap: () {},
                  ),
                  _ActionTile(
                    icon: Icons.help_outline,
                    title: "Help",
                    onTap: () {},
                  ),
                  _ActionTile(
                    icon: Icons.logout,
                    title: "Logout",
                    isDanger: true,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// ================= ACTION TILE =================
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDanger;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isDanger ? ColorConst.danger : ColorConst.accent;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorConst.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .35),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: .15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ColorConst.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
