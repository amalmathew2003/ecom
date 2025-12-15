import 'package:ecom/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../controller/auth_controller.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final AuthController controller = Get.find<AuthController>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff6A11CB), Color(0xff2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🧑‍💻 ICON
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: const Icon(
                          Icons.person_add_alt_1,
                          size: 60,
                          color: Color(0xff2575FC),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 🧾 TITLE
                      FadeIn(
                        delay: const Duration(milliseconds: 200),
                        child: const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),
                      FadeIn(
                        delay: const Duration(milliseconds: 300),
                        child: Text(
                          "Register to start shopping",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 📧 EMAIL
                      FadeInLeft(
                        delay: const Duration(milliseconds: 400),
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 🔒 PASSWORD
                      FadeInRight(
                        delay: const Duration(milliseconds: 500),
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 🚀 REGISTER BUTTON
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () {
                                      controller.register(
                                        emailController.text.trim(),
                                        passwordController.text.trim(),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xff6A11CB),
                                      Color(0xff2575FC),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: controller.isLoading.value
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          "Register",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 🔙 BACK TO LOGIN
                      FadeIn(
                        delay: const Duration(milliseconds: 700),
                        child: TextButton(
                          onPressed: () => Get.offNamed(AppRoutes.login),
                          child: const Text(
                            "Already have an account? Login",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
