import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:ecom/core/utils/responsive_layout.dart';
import 'package:ecom/features/admin/orders/controller/admin_order_controller.dart';
import 'package:ecom/features/admin/orders/ui/admin_orders_screen.dart';
import 'package:ecom/features/admin/products/ui/admin_product_list_screen.dart';
import 'package:ecom/features/auth/controller/auth_controller.dart';
import 'package:ecom/core/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NeoAdminHome extends StatelessWidget {
  const NeoAdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    // 🛡️ Admin Guard: Prevent unauthorized URL access
    final authCtrl = Get.find<AuthController>();
    final user = Supabase.instance.client.auth.currentUser;
    final isAdminVerified = false.obs;

    // Check role immediately if possible
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (user == null) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (profile?['role'] == 'admin') {
        isAdminVerified.value = true;
      } else {
        Get.offAllNamed(AppRoutes.usernav);
        Get.snackbar(
          "ACCESS DENIED",
          "YOU DO NOT HAVE ADMIN PRIVILEGES",
          backgroundColor: NeoColors.error.withOpacity(0.1),
          colorText: NeoColors.error,
        );
      }
    });

    final orderCtrl = Get.put(AdminOrderController());

    return Obx(() {
      if (!isAdminVerified.value) {
        return const Scaffold(
          backgroundColor: NeoColors.background,
          body: Center(
            child: CircularProgressIndicator(color: NeoColors.accent),
          ),
        );
      }
      return Scaffold(
        backgroundColor: NeoColors.background,
        body: ResponsiveLayout(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(authCtrl),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (ResponsiveLayout.isMobile(context)) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatsOverview(orderCtrl),
                            const SizedBox(height: 30),
                            _buildActionCards(orderCtrl),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                _buildStatsOverview(orderCtrl),
                                const SizedBox(height: 40),
                                _buildRecentActivityHeaderForWeb(),
                                _buildRecentActivityListForWeb(orderCtrl),
                              ],
                            ),
                          ),
                          const SizedBox(width: 40),
                          Expanded(
                            flex: 2,
                            child: _buildActionCards(orderCtrl),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              if (ResponsiveLayout.isMobile(context)) ...[
                _buildRecentActivityHeader(),
                _buildRecentActivityList(orderCtrl),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAppBar(AuthController auth) {
    return SliverAppBar(
      backgroundColor: NeoColors.background,
      floating: true,
      pinned: true,
      toolbarHeight: 100,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "COMMAND CENTER",
            style: GoogleFonts.oswald(
              color: NeoColors.accent,
              fontSize: 12,
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "ADM. OVERSEER",
            style: GoogleFonts.oswald(
              color: NeoColors.textHigh,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: NeoColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: IconButton(
            onPressed: () => auth.logout(),
            icon: const Icon(
              Icons.power_settings_new_rounded,
              color: NeoColors.error,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverview(AdminOrderController controller) {
    return Obx(() {
      final revenue = controller.totalRevenue.value;
      final orderCount = controller.orders.length;
      final isMobile = ResponsiveLayout.isMobile(Get.context!);

      final tiles = [
        _statTile(
          label: "TOTAL REVENUE",
          value: "₹${(revenue / 1000).toStringAsFixed(1)}K",
          icon: Icons.analytics_rounded,
          color: NeoColors.accent,
        ),
        if (!isMobile)
          const SizedBox(width: 20)
        else
          const SizedBox(height: 15),
        _statTile(
          label: "LIVE ORDERS",
          value: "$orderCount",
          icon: Icons.layers_rounded,
          color: Colors.purpleAccent,
        ),
      ];

      return isMobile ? Column(children: tiles) : Row(children: tiles);
    }).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _statTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isMobile = ResponsiveLayout.isMobile(Get.context!);
    return Expanded(
      flex: isMobile ? 0 : 1,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 20 : 30),
        decoration: BoxDecoration(
          color: NeoColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: isMobile ? 24 : 28),
            ),
            const SizedBox(height: 25),
            Text(
              value,
              style: GoogleFonts.oswald(
                color: NeoColors.textHigh,
                fontSize: isMobile ? 28 : 36,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.montserrat(
                color: NeoColors.textLow,
                fontSize: isMobile ? 8 : 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCards(AdminOrderController controller) {
    return Column(
          children: [
            _actionCard(
              title: "MANAGE ORDERS",
              subtitle: "Track, verify and assign delivery",
              onTap: () => Get.to(() => AdminOrderScreen()),
              icon: Icons.local_shipping_rounded,
              color: NeoColors.accent,
            ),
            const SizedBox(height: 20),
            _actionCard(
              title: "INVENTORY CONTROL",
              subtitle: "Add products, edit stock & price",
              onTap: () => Get.to(() => const AdminProductListScreen()),
              icon: Icons.inventory_2_rounded,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 20),
            _actionCard(
              title: "USER DATABASE",
              subtitle: "Manage customers and profiles",
              onTap: () {},
              icon: Icons.people_alt_rounded,
              color: Colors.tealAccent,
            ),
          ],
        )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 300))
        .slideX(begin: 0.1);
  }

  Widget _actionCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: NeoColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.oswald(
                        color: NeoColors.textHigh,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.montserrat(
                        color: NeoColors.textLow,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: NeoColors.textLow,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
        child: Text(
          "RECENT INTEL",
          style: GoogleFonts.oswald(
            color: NeoColors.textLow,
            fontSize: 14,
            letterSpacing: 3,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityHeaderForWeb() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        "RECENT INTEL",
        style: GoogleFonts.oswald(
          color: NeoColors.textLow,
          fontSize: 14,
          letterSpacing: 3,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildRecentActivityList(AdminOrderController controller) {
    return Obx(() {
      final recent = controller.orders.take(8).toList();
      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final order = recent[index];
          return _activityItem(order, index);
        }, childCount: recent.length),
      );
    });
  }

  Widget _buildRecentActivityListForWeb(AdminOrderController controller) {
    return Obx(() {
      final recent = controller.orders.take(8).toList();
      return Column(
        children: List.generate(
          recent.length,
          (index) => _activityItem(recent[index], index),
        ),
      );
    });
  }

  Widget _activityItem(dynamic order, int index) {
    return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: NeoColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.03)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NeoColors.background,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.token_rounded,
                  color: NeoColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ID #${order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()}",
                      style: GoogleFonts.oswald(
                        color: NeoColors.textHigh,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      order.paymentMethod,
                      style: GoogleFonts.montserrat(
                        color: NeoColors.textLow,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "₹${order.amount}",
                style: GoogleFonts.oswald(
                  color: NeoColors.accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: index * 50))
        .slideY(begin: 0.1);
  }
}
