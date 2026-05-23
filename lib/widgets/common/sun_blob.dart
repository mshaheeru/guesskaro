import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Warm radial accent (Sunny Quiz backgrounds only).
class SunBlob extends StatelessWidget {
  const SunBlob({
    super.key,
    this.top = -100,
    this.right = -120,
    this.size = 320,
    this.opacity = 1,
    this.color,
  });

  final double top;
  final double right;
  final double size;
  final double opacity;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (!AppColors.isSunny) return const SizedBox.shrink();

    final Color accent = color ?? AppColors.marigold;
    return Positioned(
      top: top,
      right: right,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[
                  accent,
                  accent.withValues(alpha: 0.33),
                  Colors.transparent,
                ],
                stops: const <double>[0.0, 0.55, 0.78],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
