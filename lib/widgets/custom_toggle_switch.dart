import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

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
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: value
              ? const LinearGradient(
                  colors: <Color>[AppColors.orange, Color(0xFFFF4500)],
                )
              : null,
          color: value ? null : Colors.white.withValues(alpha: 0.1),
          boxShadow: value
              ? const <BoxShadow>[
                  BoxShadow(color: AppColors.orangeGlow, blurRadius: 12),
                ]
              : const <BoxShadow>[],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Colors.black26, blurRadius: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
