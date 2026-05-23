import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'sun_blob.dart';

/// Paper scaffold background with optional Sunny [SunBlob].
class JpScreenBackground extends StatelessWidget {
  const JpScreenBackground({
    super.key,
    required this.child,
    this.blobColor,
    this.blobTop = -100,
    this.blobRight = -120,
    this.blobSize = 320,
    this.blobOpacity = 1,
    this.secondBlob,
  });

  final Widget child;
  final Color? blobColor;
  final double blobTop;
  final double blobRight;
  final double blobSize;
  final double blobOpacity;
  final Widget? secondBlob;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bgPrimary,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          SunBlob(
            top: blobTop,
            right: blobRight,
            size: blobSize,
            opacity: blobOpacity,
            color: blobColor,
          ),
          if (secondBlob != null) secondBlob!,
          child,
        ],
      ),
    );
  }
}
