import 'package:flutter/material.dart';

import '../core/constants/app_borders.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_shadows.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_text_styles.dart';
import 'common/jp_pressable.dart';

class JpButtonPrimary extends StatelessWidget {
  const JpButtonPrimary({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool hasUrdu = RegExp(r'[\u0600-\u06FF]').hasMatch(label);
    final TextStyle labelStyle =
        hasUrdu
            ? AppTextStyles.urduBody.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: AppColors.isSunny ? Colors.white : null,
            )
            : AppTextStyles.enTitle.copyWith(
              fontSize: 17,
              height: 1.0,
              color: AppColors.isSunny ? Colors.white : null,
            );

    if (AppColors.isSunny) {
      return JpPressable(
        onTap: onPressed,
        enabled: onPressed != null,
        child: AnimatedOpacity(
          opacity: onPressed == null ? 0.4 : 1,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: double.infinity,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.tomato,
              borderRadius: AppBorders.button,
              border: AppBorders.ink(),
              boxShadow: AppShadows.lg,
            ),
            child: Text(label, textAlign: TextAlign.center, style: labelStyle),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: <Color>[AppColors.orange, const Color(0xFFFF4500)],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(color: AppColors.orangeGlow, blurRadius: 20),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            minimumSize: const Size.fromHeight(56),
            alignment: Alignment.center,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.rButton),
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(label, textAlign: TextAlign.center, style: labelStyle),
          ),
        ),
      ),
    );
  }
}
