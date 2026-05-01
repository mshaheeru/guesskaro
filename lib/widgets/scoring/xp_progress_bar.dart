import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// XP fill within level; [fraction] ∈ [0–1].
class XpProgressBar extends StatelessWidget {
  const XpProgressBar({
    super.key,
    required this.fraction,
    this.label,
  });

  final double fraction;
  final String? label;

  @override
  Widget build(BuildContext context) {
    double t = fraction.clamp(0.0, 1.0);
    if (!t.isFinite || t <= 0) {
      t = 0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label!,
              style: Theme.of(context).textTheme.labelLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 12,
            child: LinearProgressIndicator(
              value: t <= 0 ? 0 : t.clamp(0.02, 1.0),
              minHeight: 12,
              backgroundColor: Colors.black12,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
