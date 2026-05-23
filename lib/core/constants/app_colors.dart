import 'package:flutter/material.dart';

import '../theme/app_theme_variant.dart';

/// Semantic colors for the active [AppThemeVariant].
///
/// Sync [activeVariant] from [appThemeVariantProvider] before building UI
/// (see [JhatPatApp]).
class AppColors {
  const AppColors._();

  static AppThemeVariant activeVariant = AppThemeVariant.classic;

  static bool get isSunny => activeVariant == AppThemeVariant.sunny;
  static bool get isClassic => !isSunny;

  // ── Classic (dark) ────────────────────────────────────────────────────
  static const Color _classicBgPrimary = Color(0xFF1A1A2E);
  static const Color _classicBgCard = Color(0xFF16213E);
  static const Color _classicBgElevated = Color(0xFF0F3460);
  static const Color _classicOrange = Color(0xFFFF6B35);
  static const Color _classicOrangeGlow = Color(0x40FF6B35);
  static const Color _classicOrangeDim = Color(0x1FFF6B35);
  static const Color _classicCorrect = Color(0xFF00D97E);
  static const Color _classicCorrectGlow = Color(0x3300D97E);
  static const Color _classicWrong = Color(0xFFFF4757);
  static const Color _classicWrongGlow = Color(0x33FF4757);
  static const Color _classicGold = Color(0xFFFFD700);
  static const Color _classicPurple = Color(0xFFC77DFF);
  static const Color _classicTextPrimary = Color(0xFFFFFFFF);
  static const Color _classicTextSecondary = Color(0xFF8892A4);
  static const Color _classicTextMuted = Color(0xFF4A5568);
  static const Color _classicBorderSubtle = Color(0x12FFFFFF);
  static const Color _classicBorderOrange = Color(0x66FF6B35);

  // ── Sunny Quiz (light) ──────────────────────────────────────────────────
  static const Color _sunnyPaper = Color(0xFFFFF1D6);
  static const Color _sunnyPaperWarm = Color(0xFFFCE4B6);
  static const Color _sunnyCard = Color(0xFFFFFFFF);
  static const Color _sunnyPaperShade = Color(0xFFF3D89C);
  static const Color _sunnyInk = Color(0xFF2A1810);
  static const Color _sunnyInkSoft = Color(0xFF6B5D52);
  static const Color _sunnyInkMuted = Color(0xFFA89580);
  static const Color _sunnyTomato = Color(0xFFE94F37);
  static const Color _sunnyMarigold = Color(0xFFFFB627);
  static const Color _sunnyTeal = Color(0xFF2A9D8F);
  static const Color _sunnyPurple = Color(0xFF7E57C2);
  static const Color _sunnySky = Color(0xFF5DBBE8);
  static const Color _sunnyCorrectSurface = Color(0xFFDFF3F0);
  static const Color _sunnyWrongSurface = Color(0xFFFBE0DC);

  // ── Surfaces ────────────────────────────────────────────────────────────
  static Color get bgPrimary => isSunny ? _sunnyPaper : _classicBgPrimary;
  static Color get bgCard => isSunny ? _sunnyCard : _classicBgCard;
  static Color get bgElevated => isSunny ? _sunnyPaperWarm : _classicBgElevated;

  static Color get paper => _sunnyPaper;
  static Color get paperWarm => _sunnyPaperWarm;
  static Color get card => isSunny ? _sunnyCard : _classicBgCard;
  static Color get paperShade => _sunnyPaperShade;

  // ── Ink (Sunny); mapped to classic text/borders ─────────────────────────
  static Color get ink => isSunny ? _sunnyInk : _classicTextPrimary;
  static Color get inkSoft => isSunny ? _sunnyInkSoft : _classicTextSecondary;
  static Color get inkMuted => isSunny ? _sunnyInkMuted : _classicTextMuted;

  // ── Brand / semantic ────────────────────────────────────────────────────
  static Color get orange => isSunny ? _sunnyTomato : _classicOrange;
  static Color get tomato => _sunnyTomato;
  static Color get marigold => _sunnyMarigold;
  static Color get teal => _sunnyTeal;
  static Color get sky => _sunnySky;

  static Color get orangeGlow =>
      isSunny ? _sunnyInk.withValues(alpha: 0.0) : _classicOrangeGlow;
  static Color get orangeDim =>
      isSunny ? _sunnyTomato.withValues(alpha: 0.12) : _classicOrangeDim;

  static Color get correct => isSunny ? _sunnyTeal : _classicCorrect;
  static Color get correctGlow =>
      isSunny ? _sunnyTeal.withValues(alpha: 0.35) : _classicCorrectGlow;
  static Color get wrong => isSunny ? _sunnyTomato : _classicWrong;
  static Color get wrongGlow =>
      isSunny ? _sunnyTomato.withValues(alpha: 0.35) : _classicWrongGlow;

  static Color get correctSurface =>
      isSunny ? _sunnyCorrectSurface : _classicCorrect.withValues(alpha: 0.15);
  static Color get wrongSurface =>
      isSunny ? _sunnyWrongSurface : _classicWrong.withValues(alpha: 0.15);

  static Color get gold => isSunny ? _sunnyMarigold : _classicGold;
  static Color get purple => isSunny ? _sunnyPurple : _classicPurple;

  static Color get modeQuick => tomato;
  static Color get modeLearn => purple;
  static Color get modeSpeed => marigold;
  static Color get modeCategory => teal;

  // ── Text ────────────────────────────────────────────────────────────────
  static Color get textPrimary => isSunny ? _sunnyInk : _classicTextPrimary;
  static Color get textSecondary =>
      isSunny ? _sunnyInkSoft : _classicTextSecondary;
  static Color get textMuted => isSunny ? _sunnyInkMuted : _classicTextMuted;

  // ── Borders ─────────────────────────────────────────────────────────────
  static Color get borderSubtle =>
      isSunny ? _sunnyInk.withValues(alpha: 0.12) : _classicBorderSubtle;
  static Color get borderOrange =>
      isSunny ? _sunnyInk : _classicBorderOrange;

  // ── Legacy aliases ──────────────────────────────────────────────────────
  static Color get primary => orange;
  static Color get background => bgPrimary;
  static Color get streakOrange => orange;
  static Color get timerGreen => correct;
  static Color get timerYellow => gold;
  static Color get timerRed => wrong;
}
