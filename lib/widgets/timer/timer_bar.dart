import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class TimerBar extends StatelessWidget {
  const TimerBar({super.key, required this.value});

  final double value;

  Color get _color {
    if (value > 0.6) return AppColors.correct;
    if (value > 0.3) return AppColors.gold;
    return AppColors.wrong;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: 6,
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        valueColor: AlwaysStoppedAnimation<Color>(_color),
      ),
    );
  }
}
