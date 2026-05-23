import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppShadows {
  const AppShadows._();

  // Sunny: hard offset shadows (no blur).
  static const List<BoxShadow> sm = <BoxShadow>[
    BoxShadow(color: _sunnyInk, offset: Offset(2, 2), blurRadius: 0),
  ];
  static const List<BoxShadow> md = <BoxShadow>[
    BoxShadow(color: _sunnyInk, offset: Offset(3, 3), blurRadius: 0),
  ];
  static const List<BoxShadow> lg = <BoxShadow>[
    BoxShadow(color: _sunnyInk, offset: Offset(4, 4), blurRadius: 0),
  ];
  static const List<BoxShadow> xl = <BoxShadow>[
    BoxShadow(color: _sunnyInk, offset: Offset(6, 6), blurRadius: 0),
  ];
  static const List<BoxShadow> correctMd = <BoxShadow>[
    BoxShadow(color: _sunnyTeal, offset: Offset(3, 3), blurRadius: 0),
  ];
  static const List<BoxShadow> wrongMd = <BoxShadow>[
    BoxShadow(color: _sunnyTomato, offset: Offset(3, 3), blurRadius: 0),
  ];

  static const Color _sunnyInk = Color(0xFF2A1810);
  static const Color _sunnyTeal = Color(0xFF2A9D8F);
  static const Color _sunnyTomato = Color(0xFFE94F37);

  static List<BoxShadow> cardGlow(Color color) => <BoxShadow>[
        BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 20),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 8),
        ),
      ];

  /// Card/button elevation for the active theme.
  static List<BoxShadow> get cardElevation =>
      AppColors.isSunny ? lg : cardGlow(AppColors.orange);

  static List<BoxShadow> get orangeCard => cardElevation;
  static List<BoxShadow> get correctGlow =>
      AppColors.isSunny ? correctMd : cardGlow(AppColors.correct);
  static List<BoxShadow> get wrongGlow =>
      AppColors.isSunny ? wrongMd : cardGlow(AppColors.wrong);
  static List<BoxShadow> get goldGlow => cardElevation;
}
