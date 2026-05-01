import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Backgrounds
  static const Color bgPrimary = Color(0xFF1A1A2E);
  static const Color bgCard = Color(0xFF16213E);
  static const Color bgElevated = Color(0xFF0F3460);

  // Brand
  static const Color orange = Color(0xFFFF6B35);
  static const Color orangeGlow = Color(0x40FF6B35);
  static const Color orangeDim = Color(0x1FFF6B35);

  // Semantic
  static const Color correct = Color(0xFF00D97E);
  static const Color correctGlow = Color(0x3300D97E);
  static const Color wrong = Color(0xFFFF4757);
  static const Color wrongGlow = Color(0x33FF4757);

  // Rewards
  static const Color gold = Color(0xFFFFD700);
  static const Color purple = Color(0xFFC77DFF);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8892A4);
  static const Color textMuted = Color(0xFF4A5568);

  // Borders
  static const Color borderSubtle = Color(0x12FFFFFF);
  static const Color borderOrange = Color(0x66FF6B35);

  // Legacy aliases kept for backward compatibility during migration.
  static const Color primary = orange;
  static const Color background = bgPrimary;
  static const Color streakOrange = orange;
  static const Color timerGreen = correct;
  static const Color timerYellow = gold;
  static const Color timerRed = wrong;
}
