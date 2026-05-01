import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class JpButtonPrimary extends StatelessWidget {
  const JpButtonPrimary({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool hasUrdu = RegExp(r'[\u0600-\u06FF]').hasMatch(label);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: <Color>[AppColors.orange, Color(0xFFFF4500)],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: AppColors.orangeGlow, blurRadius: 20),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            minimumSize: const Size.fromHeight(56),
            alignment: Alignment.center,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                      ? AppTextStyles.urduBody.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      )
                      : AppTextStyles.enTitle.copyWith(
                        fontSize: 18,
                        height: 1.0,
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
