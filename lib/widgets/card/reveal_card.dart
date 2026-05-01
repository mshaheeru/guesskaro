import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../common/urdu_text.dart';

class RevealPhraseCard extends StatelessWidget {
  const RevealPhraseCard({
    super.key,
    required this.urduPhrase,
    required this.romanised,
    this.surfaceColor,
  });

  final String urduPhrase;
  final String romanised;
  final Color? surfaceColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor ?? AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderOrange),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: AppColors.orangeGlow, blurRadius: 20),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            UrduText(
              urduPhrase,
              style: AppTextStyles.urduTitle,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 6),
            Text(
              romanised,
              style: AppTextStyles.enBody.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
