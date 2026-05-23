import 'package:flutter/material.dart';

import '../core/constants/app_borders.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_shadows.dart';
import '../core/constants/app_text_styles.dart';

class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (AppColors.isSunny) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.marigold,
          borderRadius: BorderRadius.circular(999),
          border: AppBorders.ink(width: AppBorders.bThin),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('🔥', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: AppTextStyles.enLabel.copyWith(fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.orangeDim,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderOrange),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: AppTextStyles.enBody.copyWith(
              color: AppColors.orange,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
