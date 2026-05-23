import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Per-phrase mastery states 0–5 (اجنبی → مکمل).
class MasteryConstants {
  const MasteryConstants._();

  static const int maxLevel = 5;

  /// Library / collection unlock tier (gold border, crown).
  static const int masteredLevel = 5;

  static bool isMastered(int level) => clampLevel(level) >= masteredLevel;

  static const Duration decayAfter = Duration(days: 7);

  static int photoOptionCountForLevel(int level) {
    if (level <= 1) return 4;
    if (level == 2) return 3;
    return 4;
  }

  static bool shouldUseImageGrid(int level) => level == 3;

  static bool shouldUseFillBlankOnReveal(int level) => level == 4;

  static int playLevelForPhrase({
    required int storedLevel,
    required bool hasScenarioUrdu,
  }) {
    if (storedLevel == 5 && !hasScenarioUrdu) return 4;
    return storedLevel.clamp(0, maxLevel);
  }

  /// Urdu mastery tier name for UI chips (via [AppStrings] in widgets).
  static int clampLevel(int level) => level.clamp(0, maxLevel);

  static Color borderColorForLevel(int level) {
    switch (clampLevel(level)) {
      case 0:
        return AppColors.textMuted.withValues(alpha: 0.45);
      case 1:
        return AppColors.borderSubtle;
      case 2:
        return const Color(0xFFE8A87C);
      case 3:
        return const Color(0xFFFFB020);
      case 4:
        return AppColors.correct;
      case 5:
        return AppColors.gold;
      default:
        return AppColors.borderSubtle;
    }
  }

  static Color dotColorForLevel(int level) {
    switch (clampLevel(level)) {
      case 0:
        return AppColors.textMuted;
      case 1:
        return AppColors.textSecondary;
      case 2:
        return const Color(0xFFE8A87C);
      case 3:
        return const Color(0xFFFFB020);
      case 4:
        return AppColors.correct;
      case 5:
        return AppColors.gold;
      default:
        return AppColors.textMuted;
    }
  }

  static double borderWidthForLevel(int level) {
    if (level <= 0) return 1;
    if (level <= 1) return 1;
    return 2;
  }

  static Color cardBackgroundForLevel(int level) {
    if (level == 0) {
      return AppColors.isSunny
          ? const Color(0xFFE8E4DC)
          : const Color(0xFF12121F);
    }
    return AppColors.bgCard;
  }

  static bool showCrownForLevel(int level) => level >= 5;
}
