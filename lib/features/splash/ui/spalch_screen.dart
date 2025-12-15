import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Icon(Icons.shopping_cart_rounded, size: 90, color: Colors.black),

            const SizedBox(height: 20),

            // App Name
            const Text(
              'E-Commerce App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 8),

          
            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }
}
