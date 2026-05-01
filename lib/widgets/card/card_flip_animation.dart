import 'dart:math' as math;

import 'package:flutter/material.dart';

class CardFlipAnimation extends StatefulWidget {
  const CardFlipAnimation({
    required this.frontWidget,
    required this.backWidget,
    super.key,
    this.duration = const Duration(milliseconds: 600),
    this.autoStart = true,
    this.onCompleted,
  });

  final Widget frontWidget;
  final Widget backWidget;
  final Duration duration;
  final bool autoStart;
  final VoidCallback? onCompleted;

  @override
  State<CardFlipAnimation> createState() => _CardFlipAnimationState();
}

class _CardFlipAnimationState extends State<CardFlipAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted?.call();
      }
    });

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final double t = Curves.easeInOut.transform(_controller.value);
        final bool showFront = t < 0.5;
        final double angle = t * math.pi;
        final double scalePulse = 1 - (0.04 * (1 - ((t - 0.5).abs() * 2)));

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle)
            ..scale(scalePulse, scalePulse),
          child: showFront
              ? widget.frontWidget
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: widget.backWidget,
                ),
        );
      },
    );
  }
}
