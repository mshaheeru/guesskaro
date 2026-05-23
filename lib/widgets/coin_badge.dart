import 'package:flutter/material.dart';

import '../core/constants/app_borders.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_shadows.dart';
import '../core/constants/app_text_styles.dart';

class CoinBadge extends StatelessWidget {
  const CoinBadge({super.key, required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    if (AppColors.isSunny) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(999),
          border: AppBorders.ink(width: AppBorders.bThin),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.marigold,
                shape: BoxShape.circle,
                border: AppBorders.ink(width: AppBorders.bThin),
              ),
              alignment: Alignment.center,
              child: Text(
                r'$',
                style: AppTextStyles.enLabel.copyWith(
                  fontSize: 11,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$amount',
              style: AppTextStyles.enLabel.copyWith(fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('🪙', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            '$amount',
            style: AppTextStyles.enBody.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
