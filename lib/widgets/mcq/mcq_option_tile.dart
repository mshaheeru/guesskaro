import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_text_styles.dart';
import '../common/urdu_text.dart';

enum McqTileAppearance {
  idle,
  selected,
  correct,
  wrong,
  eliminated,
}

class McqOptionTile extends StatelessWidget {
  const McqOptionTile({
    super.key,
    required this.label,
    required this.appearance,
    required this.onTap,
  });

  final String label;
  final McqTileAppearance appearance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool disabled =
        appearance == McqTileAppearance.eliminated || onTap == null;

    BorderSide border = const BorderSide(color: AppColors.borderSubtle, width: 1.5);
    Color bg = AppColors.bgCard;
    List<BoxShadow> boxShadow = <BoxShadow>[];

    switch (appearance) {
      case McqTileAppearance.idle:
        break;
      case McqTileAppearance.selected:
        border = const BorderSide(color: AppColors.orange, width: 1.5);
        bg = AppColors.orangeDim;
        break;
      case McqTileAppearance.correct:
        border = const BorderSide(color: AppColors.correct, width: 1.5);
        bg = AppColors.correct.withValues(alpha: 0.15);
        boxShadow = AppShadows.correctGlow;
        break;
      case McqTileAppearance.wrong:
        border = const BorderSide(color: AppColors.wrong, width: 1.5);
        bg = AppColors.wrong.withValues(alpha: 0.15);
        boxShadow = AppShadows.wrongGlow;
        break;
      case McqTileAppearance.eliminated:
        border = const BorderSide(color: AppColors.borderSubtle, width: 1.5);
        bg = AppColors.bgCard;
        break;
    }

    final Color textColor = appearance == McqTileAppearance.eliminated
        ? AppColors.textMuted
        : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.fromBorderSide(border),
            boxShadow: boxShadow,
          ),
          child: Opacity(
            opacity: appearance == McqTileAppearance.eliminated ? 0.55 : 1,
            child: UrduText(
              label,
              style: AppTextStyles.urduBody.copyWith(
                fontWeight: appearance == McqTileAppearance.idle
                    ? FontWeight.w400
                    : FontWeight.w700,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
