import 'package:flutter/material.dart';

import '../../core/constants/app_text_styles.dart';

class UrduText extends StatelessWidget {
  const UrduText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.center,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.softWrap,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    TextStyle resolvedStyle = AppTextStyles.urduBody.merge(style);
    final double currentSize = resolvedStyle.fontSize ?? 18;
    if (currentSize < 18) {
      resolvedStyle = resolvedStyle.copyWith(fontSize: 18);
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text(
        text,
        style: resolvedStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap ?? true,
      ),
    );
  }
}
