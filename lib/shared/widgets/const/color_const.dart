import 'package:flutter/material.dart';

class ColorConst {
  /// BRAND BASE - Midnight Emerald Theme
  static const primary = Color(0xFF10B981); // Vibrant Emerald
  static const secondary = Color(0xFF3B82F6); // Electric Blue
  static const accent = Color(0xFFF59E0B); // Amber Glow

  /// BACKGROUNDS
  static const bg = Color(0xFF0F172A); // Deep Slate Blue/Black
  static const card = Color(0xFF1E293B); // Slate Blue Card
  static const surface = Color(0xFF334155); // Elevated Surface

  /// TEXT
  static const textDark = Color(0xFF0F172A);
  static const textLight = Colors.white;
  static const textMuted = Color(0xFF94A3B8); // Slate 400

  /// GRADIENTS
  static const primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// COMPATIBILITY ALIASES
  static const price = accent;
  static const yellow = accent;

  /// STATUS
  static const danger = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
}
