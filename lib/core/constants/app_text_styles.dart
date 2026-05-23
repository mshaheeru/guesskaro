import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  // Urdu (Noto Nastaliq Urdu, RTL)
  static TextStyle get urduDisplay => GoogleFonts.notoNastaliqUrdu(
        fontSize: AppColors.isSunny ? 44 : 42,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: AppColors.isSunny ? 1.4 : 1.4,
      );

  static TextStyle get urduTitle => GoogleFonts.notoNastaliqUrdu(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get urduHeadline => GoogleFonts.notoNastaliqUrdu(
        fontSize: AppColors.isSunny ? 22 : 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: AppColors.isSunny ? 1.7 : 1.6,
      );

  static TextStyle get urduBody => GoogleFonts.notoNastaliqUrdu(
        fontSize: 18,
        fontWeight: AppColors.isSunny ? FontWeight.w500 : FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.8,
      );

  static TextStyle get urduCaption => GoogleFonts.notoNastaliqUrdu(
        fontSize: AppColors.isSunny ? 14 : 18,
        fontWeight: AppColors.isSunny ? FontWeight.w500 : FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
      );

  // English / numbers
  static TextStyle get enDisplay {
    if (AppColors.isSunny) {
      return GoogleFonts.nunito(
        fontSize: 64,
        fontWeight: FontWeight.w900,
        color: AppColors.tomato,
        letterSpacing: -2,
        height: 1.0,
      );
    }
    return GoogleFonts.audiowide(
      fontSize: 52,
      fontWeight: FontWeight.w400,
      color: AppColors.gold,
      letterSpacing: -1,
    );
  }

  static TextStyle get enTitle {
    if (AppColors.isSunny) {
      return GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
      );
    }
    return GoogleFonts.audiowide(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle get enBody {
    if (AppColors.isSunny) {
      return GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.inkSoft,
      );
    }
    return GoogleFonts.saira(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    );
  }

  static TextStyle get enCaption {
    if (AppColors.isSunny) {
      return GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.inkSoft,
        letterSpacing: 0.3,
      );
    }
    return GoogleFonts.saira(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textMuted,
      letterSpacing: 0.5,
    );
  }

  static TextStyle get enLabel {
    if (AppColors.isSunny) {
      return GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
        letterSpacing: 1.0,
      );
    }
    return GoogleFonts.saira(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppColors.textMuted,
      letterSpacing: 1.2,
    );
  }

  static TextStyle get urdu16 => urduBody.copyWith(fontSize: 16);
  static TextStyle get urdu22 => urduHeadline.copyWith(fontSize: 22);
  static TextStyle get urdu28Bold => urduTitle.copyWith(fontSize: 28);
  static TextStyle get latin16 => enBody.copyWith(fontSize: 16);
  static TextStyle get latin20Bold => enTitle;
}
