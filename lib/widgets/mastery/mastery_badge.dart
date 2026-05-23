import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/mastery_constants.dart';
import '../../core/locale/ui_strings.dart';
import '../common/urdu_text.dart';

/// Coloured mastery dot with optional tier label (photo card, reveal, sheets).
class MasteryBadge extends ConsumerWidget {
  const MasteryBadge({
    super.key,
    required this.level,
    this.showLabel = false,
    this.compact = false,
  });

  final int level;
  final bool showLabel;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int clamped = MasteryConstants.clampLevel(level);
    final Color color = MasteryConstants.dotColorForLevel(clamped);
    final UiStrings s = UiStrings.watch(ref);

    final Widget dot = Container(
      width: compact ? 8 : 10,
      height: compact ? 8 : 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.bgPrimary.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 4,
          ),
        ],
      ),
    );

    if (!showLabel) return dot;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        dot,
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: s.isEnglish
              ? Text(
                  s.masteryLabelForLevel(clamped),
                  style: AppTextStyles.enCaption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : UrduText(
                  s.masteryLabelForLevel(clamped),
                  style: AppTextStyles.urduCaption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ],
    );
  }
}
