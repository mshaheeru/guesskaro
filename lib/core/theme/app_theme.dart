import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'app_theme_variant.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData forVariant(AppThemeVariant variant) {
    final bool sunny = variant == AppThemeVariant.sunny;
    AppColors.activeVariant = variant;

    return ThemeData(
      useMaterial3: true,
      brightness: sunny ? Brightness.light : Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      colorScheme: sunny
          ? ColorScheme.light(
              primary: AppColors.orange,
              secondary: AppColors.gold,
              tertiary: AppColors.teal,
              surface: AppColors.bgCard,
              error: AppColors.wrong,
              onPrimary: Colors.white,
              onSurface: AppColors.ink,
            )
          : ColorScheme.dark(
              primary: AppColors.orange,
              secondary: AppColors.gold,
              surface: AppColors.bgCard,
              error: AppColors.wrong,
            ),
      splashFactory: sunny ? NoSplash.splashFactory : InkSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      fontFamily: sunny ? GoogleFonts.nunito().fontFamily : null,
      textTheme: _textTheme(sunny),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: sunny ? Colors.white : AppColors.textPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              sunny ? AppSpacing.rButton : 16,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: BorderSide(color: AppColors.borderSubtle, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              sunny ? AppSpacing.rButton : 16,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgCard,
        hintStyle: AppTextStyles.enBody.copyWith(color: AppColors.textMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            sunny ? AppSpacing.rInput : 16,
          ),
          borderSide: BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            sunny ? AppSpacing.rInput : 16,
          ),
          borderSide: BorderSide(color: AppColors.borderOrange),
        ),
      ),
    );
  }

  static TextTheme _textTheme(bool sunny) {
    final TextTheme base = sunny
        ? GoogleFonts.nunitoTextTheme(const TextTheme())
        : GoogleFonts.sairaTextTheme(const TextTheme());
    return base.copyWith(
      headlineLarge: AppTextStyles.enDisplay,
      headlineMedium: AppTextStyles.enTitle,
      titleLarge: AppTextStyles.enTitle,
      titleMedium: AppTextStyles.enBody,
      bodyLarge: AppTextStyles.enBody,
      bodyMedium: AppTextStyles.enCaption,
      labelMedium: AppTextStyles.enLabel,
    );
  }

  /// Default theme (classic dark).
  static ThemeData get lightTheme => forVariant(AppThemeVariant.classic);
}
