import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> cardGlow(Color color) => <BoxShadow>[
        BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 20),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get orangeCard => cardGlow(AppColors.orange);
  static List<BoxShadow> get correctGlow => cardGlow(AppColors.correct);
  static List<BoxShadow> get wrongGlow => cardGlow(AppColors.wrong);
  static List<BoxShadow> get goldGlow => cardGlow(AppColors.gold);
}
