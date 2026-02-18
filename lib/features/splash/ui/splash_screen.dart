import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ecom/core/theme/neo_colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Container
            Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: NeoColors.textHigh, width: 3),
                  ),
                  child: Text(
                    "NEO",
                    style: GoogleFonts.oswald(
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      color: NeoColors.textHigh,
                      letterSpacing: 10,
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack)
                .then()
                .shimmer(duration: 2.seconds, color: NeoColors.accent),

            const SizedBox(height: 30),

            // Tagline
            Text(
              "PREMIUM EVOLUTION",
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: NeoColors.accent,
                letterSpacing: 4,
              ),
            ).animate(delay: 500.ms).fadeIn().slideY(begin: 1),

            const SizedBox(height: 100),

            // Loading Indicator
            SizedBox(
              width: 150,
              child: LinearProgressIndicator(
                backgroundColor: NeoColors.surface,
                color: NeoColors.accent,
                minHeight: 1,
              ),
            ).animate(delay: 800.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}
