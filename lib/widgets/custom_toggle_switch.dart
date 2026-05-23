import 'package:flutter/material.dart';

import '../core/constants/app_borders.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_shadows.dart';

class CustomToggleSwitch extends StatelessWidget {
  const CustomToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    if (AppColors.isSunny) {
      return GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: 52,
          height: 30,
          decoration: BoxDecoration(
            color: value ? AppColors.teal : AppColors.paperWarm,
            borderRadius: BorderRadius.circular(999),
            border: AppBorders.ink(width: AppBorders.bDefault),
            boxShadow: AppShadows.sm,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            alignment:
                value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.all(2),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: AppBorders.ink(width: AppBorders.bThin),
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient:
              value
                  ? LinearGradient(
                    colors: <Color>[AppColors.orange, const Color(0xFFFF4500)],
                  )
                  : null,
          color: value ? null : Colors.white.withValues(alpha: 0.1),
          boxShadow:
              value
                  ? <BoxShadow>[
                    BoxShadow(color: AppColors.orangeGlow, blurRadius: 12),
                  ]
                  : <BoxShadow>[],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(color: Colors.black26, blurRadius: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
