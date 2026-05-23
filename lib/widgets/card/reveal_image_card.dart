import 'package:flutter/material.dart';

import '../../core/constants/app_borders.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../common/urdu_text.dart';

/// Phrase reveal panel (no background image) — shows the correct idiom after photo round.
class RevealImageCard extends StatelessWidget {
  const RevealImageCard({
    super.key,
    required this.urduPhrase,
    this.romanised,
    this.subtitle,
  });

  final String urduPhrase;
  final String? romanised;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.isSunny ? AppColors.card : AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.rCard),
        border: AppColors.isSunny
            ? AppBorders.ink()
            : Border.all(color: AppColors.borderOrange, width: 1.5),
        boxShadow: AppColors.isSunny
            ? AppShadows.lg
            : <BoxShadow>[
                BoxShadow(color: AppColors.orangeGlow, blurRadius: 20),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
            Text(
              subtitle!,
              style: AppTextStyles.enLabel.copyWith(
                color: AppColors.isSunny ? AppColors.tomato : AppColors.orange,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
          UrduText(
            urduPhrase,
            style: AppTextStyles.urduTitle.copyWith(
              fontSize: 30,
              color: AppColors.isSunny ? AppColors.ink : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (romanised != null && romanised!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              romanised!,
              style: AppTextStyles.enBody.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
