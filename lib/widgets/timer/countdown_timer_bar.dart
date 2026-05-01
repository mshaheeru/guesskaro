import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Linear countdown with urgency colors; [frozen] highlights frozen state.
class CountdownTimerBar extends StatelessWidget {
  const CountdownTimerBar({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
    this.frozen = false,
    this.height = 10,
    this.enabled = true,
  });

  final int totalSeconds;
  final int remainingSeconds;
  final bool frozen;
  final double height;
  /// When false, shows a muted full bar (e.g. untimed rounds).
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled || totalSeconds <= 0) {
      return SizedBox(
        height: height + 6,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: 1,
              minHeight: height,
              backgroundColor: Colors.black12,
              color: frozen ? Colors.blue.shade200 : Colors.grey.shade400,
            ),
          ),
        ),
      );
    }

    final double ratio = remainingSeconds / totalSeconds;
    Color track = AppColors.timerGreen;
    if (ratio <= 0.33) {
      track = AppColors.timerRed;
    } else if (ratio <= 0.67) {
      track = AppColors.timerYellow;
    }

    final Color fg = frozen ? Colors.blue.shade400 : track;

    return Semantics(
      label: '${remainingSeconds.toString()} سیکنڈ',
      child: SizedBox(
        height: height + 6,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.02, 1.0),
              minHeight: height,
              backgroundColor: Colors.black12,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
