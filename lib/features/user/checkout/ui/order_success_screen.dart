import 'package:ecom/core/theme/neo_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.greenAccent.withOpacity(0.1),
                      border: Border.all(
                        color: Colors.greenAccent.withOpacity(0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.greenAccent,
                      size: 60,
                    ),
                  )
                  .animate()
                  .scale(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                  )
                  .rotate(begin: 0.5),
              const SizedBox(height: 40),
              Text(
                    "MISSION ACCOMPLISHED",
                    style: GoogleFonts.oswald(
                      color: NeoColors.textHigh,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 400))
                  .slideY(begin: 0.2),
              const SizedBox(height: 15),
              Text(
                "YOUR ELITE GEAR IS BEING PREPARED FOR DEPLOYMENT.",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: NeoColors.textLow,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ).animate(delay: const Duration(milliseconds: 600)).fadeIn(),
              const SizedBox(height: 60),
              GestureDetector(
                    onTap: () => Get.offAllNamed('/user-nav'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: NeoColors.textHigh,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          "CONTINUE EXPLORING",
                          style: GoogleFonts.oswald(
                            color: NeoColors.background,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  )
                  .animate(delay: const Duration(milliseconds: 1000))
                  .fadeIn()
                  .scale(),
            ],
          ),
        ),
      ),
    );
  }
}
