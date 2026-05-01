import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/scoring_constants.dart';

class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.streak, this.isEnglish = false});

  final int streak;
  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    if (streak < 3) return const SizedBox.shrink();

    final String flare = ScoringConstants.getStreakLabel(
      streak,
      isEnglish: isEnglish,
    );
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.streakOrange.withValues(alpha: 0.15),
        border: Border.all(color: AppColors.streakOrange),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.streakOrange,
              child: Text(
                '$streak',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                flare.isNotEmpty ? flare : (isEnglish ? 'Keep it going!' : 'سلسلہ جاری ہے!'),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.deepOrange.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
