import 'package:ecom/features/admin/users/controller/admin_user_controller.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminUserScreen extends StatelessWidget {
  AdminUserScreen({super.key});

  final controller = Get.put(AdminUserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'User Management',
          style: TextStyle(
            color: ColorConst.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddStaffDialog(context),
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              color: ColorConst.primary,
            ),
            tooltip: "Add Staff Member",
          ),
          const SizedBox(width: 10),
        ],
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ColorConst.textLight,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.users.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: ColorConst.primary),
          );
        }

        return Column(
          children: [
            /// 📊 STATS CARDS
            _buildStatsHeader(),

            /// 🔍 SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: ColorConst.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColorConst.surface, width: 1.5),
                ),
                child: TextField(
                  onChanged: (val) => controller.searchQuery.value = val,
                  style: const TextStyle(color: ColorConst.textLight),
                  decoration: const InputDecoration(
                    hintText: "Search by name, email or phone...",
                    hintStyle: TextStyle(
                      color: ColorConst.textMuted,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: ColorConst.primary,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 🔍 FILTERS
            _buildFilters(),

            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Filtered Members",
                  style: TextStyle(
                    color: ColorConst.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            /// 👥 USER LIST
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.fetchUsers(),
                color: ColorConst.primary,
                child: Obx(() {
                  if (controller.filteredUsers.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.15,
                        ),
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.group_off_rounded,
                                size: 64,
                                color: ColorConst.textMuted.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "No members found in this category",
                                style: TextStyle(color: ColorConst.textMuted),
                              ),
                              TextButton(
                                onPressed: () => controller.fetchUsers(),
                                child: const Text("Tap to Refresh"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = controller.filteredUsers[index];
                      return _buildUserCard(user);
                    },
                  );
                }),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _statTile(
            "Total Members",
            controller.totalUsers.value.toString(),
            ColorConst.primary,
          ),
          const SizedBox(width: 12),
          _statTile(
            "Staff Count",
            controller.staffCount.value.toString(),
            const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip("All", 'all'),
          const SizedBox(width: 8),
          _filterChip("Staff", 'staff'),
          const SizedBox(width: 8),
          _filterChip("Delivery", 'delivery'),
          const SizedBox(width: 8),
          _filterChip("Customers", 'user'),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String role) {
    return Obx(() {
      final isSelected = controller.filterRole.value == role;
      return GestureDetector(
        onTap: () => controller.filterRole.value = role,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? ColorConst.primary : ColorConst.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? ColorConst.primary : ColorConst.surface,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : ColorConst.textMuted,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      );
    });
  }

  Widget _statTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: ColorConst.textLight,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: ColorConst.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(user) {
    final role = user.role.toString().toLowerCase();
    Color roleColor;
    IconData roleIcon;

    if (role == 'admin') {
      roleColor = const Color(0xFFF59E0B);
      roleIcon = Icons.admin_panel_settings_rounded;
    } else if (role == 'staff') {
      roleColor = const Color(0xFF6366F1);
      roleIcon = Icons.badge_rounded;
    } else {
      roleColor = ColorConst.textMuted;
      roleIcon = Icons.person_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConst.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorConst.surface, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: roleColor.withValues(alpha: 0.1),
                child: Icon(roleIcon, color: roleColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        color: ColorConst.textLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(
                        color: ColorConst.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _roleDropdown(user),
            ],
          ),
          if (user.phone.isNotEmpty || user.address.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: ColorConst.surface, height: 1),
            ),
            Row(
              children: [
                if (user.phone.isNotEmpty) ...[
                  const Icon(
                    Icons.phone_iphone_rounded,
                    size: 14,
                    color: ColorConst.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    user.phone,
                    style: const TextStyle(
                      color: ColorConst.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (user.phone.isNotEmpty && user.address.isNotEmpty)
                  const SizedBox(width: 16),
                if (user.address.isNotEmpty) ...[
                  const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      user.address,
                      style: const TextStyle(
                        color: ColorConst.textMuted,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _roleDropdown(user) {
    // Safety check: ensure current role is valid for dropdown, default to 'user' if not.
    final currentRole =
        [
          'user',
          'staff',
          'delivery',
          'admin',
        ].contains(user.role.toLowerCase().trim())
        ? user.role.toLowerCase().trim()
        : 'user';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: ColorConst.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: ColorConst.card,
          value: currentRole,
          items: ['user', 'staff', 'delivery', 'admin'].map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(
                role.toUpperCase(),
                style: const TextStyle(
                  color: ColorConst.textLight,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
          onChanged: (newRole) {
            if (newRole != null) {
              controller.updateRole(user.id, newRole);
            }
          },
        ),
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final selectedRole = 'staff'.obs;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorConst.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Register Team Member",
          style: TextStyle(color: ColorConst.textLight),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Role Selector
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => selectedRole.value = 'staff',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedRole.value == 'staff'
                              ? ColorConst.primary
                              : ColorConst.bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '🛠️ Staff',
                            style: TextStyle(
                              color: selectedRole.value == 'staff'
                                  ? Colors.white
                                  : ColorConst.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => selectedRole.value = 'delivery',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedRole.value == 'delivery'
                              ? Colors.blue
                              : ColorConst.bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '🚚 Delivery',
                            style: TextStyle(
                              color: selectedRole.value == 'delivery'
                                  ? Colors.white
                                  : ColorConst.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _dialogField(emailCtrl, "Email", Icons.email_rounded),
            const SizedBox(height: 12),
            _dialogField(nameCtrl, "Full Name", Icons.person_rounded),
            const SizedBox(height: 12),
            _dialogField(
              passwordCtrl,
              "Password",
              Icons.lock_rounded,
              isPassword: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          Obx(
            () => ElevatedButton(
              onPressed: () {
                if (emailCtrl.text.isNotEmpty &&
                    passwordCtrl.text.isNotEmpty &&
                    nameCtrl.text.isNotEmpty) {
                  controller.registerTeamMember(
                    email: emailCtrl.text.trim(),
                    password: passwordCtrl.text.trim(),
                    name: nameCtrl.text.trim(),
                    role: selectedRole.value,
                  );
                  Get.back();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedRole.value == 'delivery'
                    ? Colors.blue
                    : ColorConst.primary,
              ),
              child: Text("Register ${selectedRole.value.toUpperCase()}"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword,
      style: const TextStyle(color: ColorConst.textLight),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: ColorConst.textMuted),
        prefixIcon: Icon(icon, color: ColorConst.primary, size: 20),
        filled: true,
        fillColor: ColorConst.bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
