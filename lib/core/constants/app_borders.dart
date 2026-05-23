import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

class AppBorders {
  const AppBorders._();

  static const double bThin = 2.0;
  static const double bDefault = 2.5;
  static const double bThick = 3.0;

  static Border ink({double width = bDefault}) =>
      Border.all(color: AppColors.ink, width: width);

  static BorderRadius get card => BorderRadius.circular(AppSpacing.rCard);
  static BorderRadius get button => BorderRadius.circular(AppSpacing.rButton);
  static BorderRadius get tile => BorderRadius.circular(AppSpacing.rTile);
}
