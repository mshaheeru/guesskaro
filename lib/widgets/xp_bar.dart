import 'package:flutter/material.dart';

import '../core/constants/app_borders.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_shadows.dart';
import '../core/constants/app_text_styles.dart';

class XpBar extends StatelessWidget {
  const XpBar({super.key, required this.level, required this.xpPct});

  final int level;
  final double xpPct;

  @override
  Widget build(BuildContext context) {
    if (AppColors.isSunny) {
      return Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.tomato,
              borderRadius: BorderRadius.circular(11),
              border: AppBorders.ink(width: AppBorders.bThin),
              boxShadow: AppShadows.sm,
            ),
            alignment: Alignment.center,
            child: Text(
              '$level',
              style: AppTextStyles.enTitle.copyWith(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.paperWarm,
                borderRadius: BorderRadius.circular(999),
                border: AppBorders.ink(width: AppBorders.bThin),
              ),
              clipBehavior: Clip.hardEdge,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: xpPct.clamp(0, 1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      border: Border(
                        right: BorderSide(color: AppColors.ink, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: <Widget>[
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(10),
            boxShadow: <BoxShadow>[
              BoxShadow(color: AppColors.orangeGlow, blurRadius: 10),
            ],
          ),
          child: Center(
            child: Text(
              '$level',
              style: AppTextStyles.enTitle.copyWith(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: xpPct.clamp(0, 1),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
            ),
          ),
        ),
      ],
    );
  }
}
