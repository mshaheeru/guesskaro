import 'package:flutter/material.dart';

import '../core/constants/app_borders.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_shadows.dart';
import '../core/constants/app_text_styles.dart';
import 'common/jp_pressable.dart';

class JpButtonGhost extends StatelessWidget {
  const JpButtonGhost({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool hasUrdu = RegExp(r'[\u0600-\u06FF]').hasMatch(label);
    final TextStyle labelStyle =
        hasUrdu
            ? AppTextStyles.urduBody.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: AppColors.isSunny ? AppColors.ink : null,
            )
            : AppTextStyles.enBody.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.isSunny ? AppColors.ink : AppColors.textSecondary,
              height: 1.0,
            );

    if (AppColors.isSunny) {
      return JpPressable(
        onTap: onPressed,
        enabled: onPressed != null,
        child: Container(
          width: double.infinity,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppBorders.button,
            border: AppBorders.ink(),
            boxShadow: AppShadows.lg,
          ),
          child: Text(label, textAlign: TextAlign.center, style: labelStyle),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          padding: EdgeInsets.zero,
          minimumSize: const Size.fromHeight(54),
          alignment: Alignment.center,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide(color: AppColors.borderSubtle, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(label, textAlign: TextAlign.center, style: labelStyle),
        ),
      ),
    );
  }
}
