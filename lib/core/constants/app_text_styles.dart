import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  // Urdu (Noto Nastaliq Urdu, RTL, textAlign: TextAlign.right)
  static TextStyle get urduDisplay => GoogleFonts.notoNastaliqUrdu(
    fontSize: 42,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get urduTitle => GoogleFonts.notoNastaliqUrdu(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get urduHeadline => GoogleFonts.notoNastaliqUrdu(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static TextStyle get urduBody => GoogleFonts.notoNastaliqUrdu(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.8,
  );

  static TextStyle get urduCaption => GoogleFonts.notoNastaliqUrdu(
    fontSize: 18,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  // English / Numbers (Poppins, LTR)
  static TextStyle get enDisplay => GoogleFonts.audiowide(
    fontSize: 52,
    fontWeight: FontWeight.w400,
    color: AppColors.gold,
    letterSpacing: -1,
  );

  static TextStyle get enTitle => GoogleFonts.audiowide(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get enBody => GoogleFonts.saira(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get enCaption => GoogleFonts.saira(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.5,
  );

  static TextStyle get enLabel => GoogleFonts.saira(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    letterSpacing: 1.2,
  );

  // Legacy style aliases kept while migrating remaining files.
  static TextStyle get urdu16 => urduBody.copyWith(fontSize: 16);
  static TextStyle get urdu22 => urduHeadline.copyWith(fontSize: 22);
  static TextStyle get urdu28Bold => urduTitle.copyWith(fontSize: 28);
  static TextStyle get latin16 => enBody.copyWith(fontSize: 16);
  static TextStyle get latin20Bold => enTitle;
}
