import 'package:flutter/material.dart';

import '../../core/constants/app_borders.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/layout/bottom_inset.dart';
import '../common/urdu_text.dart';
import '../jp_button_primary.dart';

/// Full-screen story narration beat; user taps Next to continue.
class StoryConnectorCard extends StatelessWidget {
  const StoryConnectorCard({
    super.key,
    required this.connectorText,
    required this.nextLabel,
    required this.onNext,
  });

  final String connectorText;
  final String nextLabel;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInsetGap(context, gap: 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _NarrationCard(text: connectorText),
                ),
              ),
            ),
            const SizedBox(height: 20),
            JpButtonPrimary(label: nextLabel, onPressed: onNext),
          ],
        ),
      ),
    );
  }
}

class _NarrationCard extends StatelessWidget {
  const _NarrationCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final Widget body = AppColors.isSunny
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppBorders.tile,
              border: AppBorders.ink(),
              boxShadow: AppShadows.lg,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: UrduText(
                text,
                style: AppTextStyles.urduTitle.copyWith(
                  fontSize: 22,
                  height: 1.75,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: UrduText(
                text,
                style: AppTextStyles.urduTitle.copyWith(
                  fontSize: 22,
                  height: 1.75,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );

    return body;
  }
}
