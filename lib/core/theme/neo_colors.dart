import 'package:flutter/material.dart';

class NeoColors {
  // 1. Updated Backgrounds for better depth
  static const Color background = Color(0xFF030303); // Deepest Black
  static const Color surface = Color(0xFF141414); // Soft Dark

  // 2. New "Acid Lime" Accent for high-contrast Cyber look
  static const Color accent = Color(0xFFC7FF00); // Acid Lime

  // 3. Status Colors
  static const Color primary = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFFF3333); // Neon Red
  static const Color success = Color(0xFF00FF94); // Spring Green

  // 4. Typography
  static const Color textHigh = Color(0xFFFFFFFF);
  static const Color textMedium = Color(0xFF999999);
  static const Color textLow = Color(0xFF444444);
  static const Color foreground = Color(0xFFFFFFFF);

  // 5. Updated Gradients
  static LinearGradient get premiumGradient => const LinearGradient(
    colors: [Color(0xFFC7FF00), Color(0xFF9DFF00)], // Lime Gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get glassGradient => LinearGradient(
    colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 6. Cyber Gradients (Optional usage)
  static LinearGradient get cyberGradient => const LinearGradient(
    colors: [Color(0xFFC7FF00), Color(0xFF00E5FF)], // Lime to Cyan
  );
}
