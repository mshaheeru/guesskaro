import 'package:flutter/material.dart';

import '../core/constants/app_borders.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_shadows.dart';
class JpCard extends StatelessWidget {
  JpCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    Color? glowColor,
  }) : glowColor = glowColor ?? AppColors.orange;

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    if (AppColors.isSunny) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppBorders.card,
          border: AppBorders.ink(),
          boxShadow: AppShadows.lg,
        ),
        child: child,
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderOrange, width: 1),
        boxShadow: AppShadows.cardGlow(glowColor),
      ),
      child: child,
    );
  }
}
