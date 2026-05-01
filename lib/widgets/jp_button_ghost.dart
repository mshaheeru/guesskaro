import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class JpButtonGhost extends StatelessWidget {
  const JpButtonGhost({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool hasUrdu = RegExp(r'[\u0600-\u06FF]').hasMatch(label);
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          padding: EdgeInsets.zero,
          minimumSize: const Size.fromHeight(54),
          alignment: Alignment.center,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style:
                hasUrdu
                    ? AppTextStyles.urduBody.copyWith(height: 1.2)
                    : AppTextStyles.enBody.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.0,
                    ),
          ),
        ),
      ),
    );
  }
}
