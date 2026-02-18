import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:ecom/core/theme/neo_colors.dart';
import 'package:ecom/features/auth/controller/auth_controller.dart';

class NeoRegisterPage extends StatelessWidget {
  NeoRegisterPage({super.key});

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final authCtrl = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.background,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -100,
            child: Icon(
              Icons.blur_on_rounded,
              size: 400,
              color: NeoColors.accent.withOpacity(0.05),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: NeoColors.textHigh,
                      size: 20,
                    ),
                  ).animate().fadeIn().slideX(begin: 0.2),

                  const SizedBox(height: 40),

                  Text(
                    "JOIN NEO",
                    style: GoogleFonts.oswald(
                      color: NeoColors.textHigh,
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ).animate().fadeIn().slideX(begin: -0.2),
                  Text(
                    "Start your journey into the futuristic marketplace.",
                    style: GoogleFonts.montserrat(
                      color: NeoColors.textMedium,
                      fontSize: 14,
                    ),
                  ).animate(delay: const Duration(milliseconds: 200)).fadeIn(),

                  const SizedBox(height: 50),

                  _buildTextField(
                        label: "FULL NAME",
                        controller: nameCtrl,
                        icon: Icons.person_outline_rounded,
                      )
                      .animate(delay: const Duration(milliseconds: 400))
                      .fadeIn()
                      .slideY(begin: 0.1),

                  const SizedBox(height: 25),

                  _buildTextField(
                        label: "EMAIL ADDRESS",
                        controller: emailCtrl,
                        icon: Icons.alternate_email_rounded,
                      )
                      .animate(delay: const Duration(milliseconds: 600))
                      .fadeIn()
                      .slideY(begin: 0.1),

                  const SizedBox(height: 25),

                  _buildTextField(
                        label: "PASSWORD",
                        controller: passCtrl,
                        icon: Icons.lock_open_rounded,
                        isPassword: true,
                      )
                      .animate(delay: const Duration(milliseconds: 800))
                      .fadeIn()
                      .slideY(begin: 0.1),

                  const SizedBox(height: 50),

                  Obx(
                    () => _buildPrimaryButton(
                      text: authCtrl.isLoading.value
                          ? "CREATING..."
                          : "REGISTER",
                      onPressed: () => authCtrl.register(
                        emailCtrl.text,
                        passCtrl.text,
                        nameCtrl.text,
                      ),
                    ),
                  ).animate(delay: const Duration(seconds: 1)).fadeIn().scale(),

                  const SizedBox(height: 30),

                  Center(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: RichText(
                        text: TextSpan(
                          text: "Already a member? ",
                          style: GoogleFonts.montserrat(
                            color: NeoColors.textLow,
                          ),
                          children: [
                            TextSpan(
                              text: "LOG IN",
                              style: const TextStyle(
                                color: NeoColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate(delay: const Duration(milliseconds: 1200)).fadeIn(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.oswald(
            color: NeoColors.textLow,
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: GoogleFonts.montserrat(color: NeoColors.textHigh),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: NeoColors.accent, size: 20),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: NeoColors.surface),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: NeoColors.accent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: NeoColors.textHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.oswald(
              color: NeoColors.background,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
