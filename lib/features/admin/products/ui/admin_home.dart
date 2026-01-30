import 'package:animate_do/animate_do.dart';
import 'package:ecom/features/admin/orders/controller/admin_order_controller.dart';
import 'package:ecom/features/admin/users/ui/admin_users_screen.dart';
import 'package:ecom/features/admin/orders/ui/admin_orders_screen.dart';
import 'package:ecom/features/admin/products/ui/admin_product_list_screen.dart';
import 'package:ecom/features/auth/controller/auth_controller.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final orderCtrl = Get.put(AdminOrderController());
  final authCtrl = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ADMINISTRATOR",
              style: TextStyle(
                color: ColorConst.primary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            Text(
              'Superview Console',
              style: TextStyle(
                color: ColorConst.textLight,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => authCtrl.logout(),
            icon: const Icon(Icons.logout_rounded, color: ColorConst.danger),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            /// 📊 EXECUTIVE ANALYTICS
            _buildExecutiveStats(),

            const SizedBox(height: 40),

            /// 👥 STAFFING SECTION (Primary Admin Duty)
            _sectionHeader("Staffing & Security"),
            _buildStaffOnboardingCard(),
            const SizedBox(height: 16),
            _buildStaffManagementTile(),

            const SizedBox(height: 24),

            /// ⚙️ OPERATIONS CENTER (Orders & Inventory)
            _sectionHeader("Operations Center"),
            _buildOperationsGrid(),

            const SizedBox(height: 24),

            /// 📈 FINANCIAL OVERSIGHT
            _sectionHeader("Financial Insights"),
            _buildFinanceCard(),

            const SizedBox(height: 32),

            /// 📜 AUDIT LOG (Recent Activity Recap)
            _sectionHeader("Recent Commercial Activity"),
            _buildRecentActivityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutiveStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(
        () => Row(
          children: [
            _statCard(
              'Revenue',
              '₹${(orderCtrl.totalRevenue.value / 1000).toStringAsFixed(1)}k',
              Icons.analytics_rounded,
              ColorConst.primary,
            ),
            const SizedBox(width: 15),
            _statCard(
              'Total Sales',
              orderCtrl.orders.length.toString(),
              Icons.shopping_bag_rounded,
              const Color(0xFFF59E0B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffManagementTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FadeInUp(
        child: InkWell(
          onTap: () => Get.to(() => AdminUserScreen()),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: ColorConst.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: ColorConst.primary.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorConst.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.people_alt_rounded,
                    color: ColorConst.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Staff & User Roles",
                        style: TextStyle(
                          color: ColorConst.textLight,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Register new staff members or change permissions.",
                        style: TextStyle(
                          color: ColorConst.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: ColorConst.primary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Store Balance",
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  "Settled Revenue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Obx(
              () => Text(
                "₹${orderCtrl.totalRevenue.value.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: ColorConst.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    return Obx(() {
      final recent = orderCtrl.orders.take(5).toList();
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: recent.length,
        itemBuilder: (context, index) {
          final order = recent[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorConst.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sale ID #${order.id.substring(0, 6)}",
                      style: const TextStyle(
                        color: ColorConst.textLight,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      order.paymentMethod,
                      style: const TextStyle(
                        color: ColorConst.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Text(
                  "+₹${order.amount.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildStaffOnboardingCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Need more hands?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Onboard a new staff member to manage orders and inventory.",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.to(() => AdminUserScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      "Register Staff Now",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.badge_rounded, color: Colors.white30, size: 80),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          color: ColorConst.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ColorConst.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: ColorConst.surface),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: ColorConst.textLight,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: ColorConst.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _opCard(
              "Orders",
              Icons.local_shipping_rounded,
              Colors.blueAccent,
              () => Get.to(() => AdminOrderScreen()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _opCard(
              "Inventory",
              Icons.inventory_2_rounded,
              Colors.purpleAccent,
              () => Get.to(() => const AdminProductListScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _opCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: ColorConst.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: ColorConst.textLight,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
