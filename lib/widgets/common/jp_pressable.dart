import 'package:flutter/material.dart';

import '../../core/constants/app_shadows.dart';

/// Chunky press-down: translate (2,2) and shrink hard shadow (Sunny Quiz).
class JpPressable extends StatefulWidget {
  const JpPressable({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.shadowRest = AppShadows.lg,
    this.shadowPressed = AppShadows.sm,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final List<BoxShadow> shadowRest;
  final List<BoxShadow> shadowPressed;

  @override
  State<JpPressable> createState() => _JpPressableState();
}

class _JpPressableState extends State<JpPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || widget.onTap == null) {
      return widget.child;
    }

    final double offset = _pressed ? 2 : 0;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(offset, offset, 0),
        child: widget.child,
      ),
    );
  }
}
