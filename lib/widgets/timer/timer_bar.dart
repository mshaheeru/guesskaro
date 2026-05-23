import 'package:flutter/material.dart';

import '../../core/constants/app_borders.dart';
import '../../core/constants/app_colors.dart';

class TimerBar extends StatefulWidget {
  const TimerBar({super.key, required this.value});

  final double value;

  @override
  State<TimerBar> createState() => _TimerBarState();
}

class _TimerBarState extends State<TimerBar>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;

  Color get _color {
    if (widget.value > 0.6) return AppColors.correct;
    if (widget.value > 0.3) return AppColors.gold;
    return AppColors.wrong;
  }

  @override
  void didUpdateWidget(TimerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  @override
  void initState() {
    super.initState();
    _syncPulse();
  }

  void _syncPulse() {
    final bool danger = AppColors.isSunny && widget.value < 0.3;
    if (danger && _pulseController == null) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      )..repeat(reverse: true);
    } else if (!danger && _pulseController != null) {
      _pulseController!.dispose();
      _pulseController = null;
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AppColors.isSunny) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: widget.value.clamp(0, 1),
          minHeight: 6,
          backgroundColor: Colors.white.withValues(alpha: 0.08),
          valueColor: AlwaysStoppedAnimation<Color>(_color),
        ),
      );
    }

    Widget fill = AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: _color,
        border:
            widget.value > 0.05
                ? Border(right: BorderSide(color: AppColors.ink, width: 2))
                : null,
      ),
    );

    if (_pulseController != null) {
      fill = AnimatedBuilder(
        animation: _pulseController!,
        builder: (BuildContext context, Widget? child) {
          return Transform.scale(
            scaleY: 1.0 + (_pulseController!.value * 0.4),
            alignment: Alignment.centerLeft,
            child: child,
          );
        },
        child: fill,
      );
    }

    return Container(
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
          widthFactor: widget.value.clamp(0, 1),
          child: fill,
        ),
      ),
    );
  }
}
