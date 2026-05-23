import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_borders.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_text_styles.dart';

class Sticker extends StatelessWidget {
  const Sticker({
    super.key,
    required this.text,
    this.color,
    this.textColor,
    this.rotateDeg = -4,
  });

  final String text;
  final Color? color;
  final Color? textColor;
  final double rotateDeg;

  @override
  Widget build(BuildContext context) {
    if (!AppColors.isSunny) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color ?? AppColors.orangeDim,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderOrange),
        ),
        child: Text(
          text,
          style: AppTextStyles.enCaption.copyWith(
            color: textColor ?? AppColors.orange,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final Color bg = color ?? AppColors.marigold;
    final Color fg = textColor ?? AppColors.ink;
    return Transform.rotate(
      angle: rotateDeg * math.pi / 180,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: AppBorders.ink(width: AppBorders.bThin),
          boxShadow: AppShadows.sm,
        ),
        child: Text(
          text,
          style: AppTextStyles.enLabel.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: fg,
          ),
        ),
      ),
    );
  }
}
