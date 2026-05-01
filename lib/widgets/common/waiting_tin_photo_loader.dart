import 'package:flutter/material.dart';

/// Gentle pulse scale while a phrase photo is loading ([waitingtin.png]).
class WaitingTinPhotoLoader extends StatefulWidget {
  const WaitingTinPhotoLoader({super.key});

  static const String assetPath = 'assets/images/waitingtin.png';

  @override
  State<WaitingTinPhotoLoader> createState() => _WaitingTinPhotoLoaderState();
}

class _WaitingTinPhotoLoaderState extends State<WaitingTinPhotoLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..repeat(reverse: true);

  late final Animation<double> _scale = Tween<double>(begin: 0.94, end: 1.06)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF2F2F2),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double side = (constraints.biggest.shortestSide * 0.42)
              .clamp(72.0, 200.0);
          return Center(
            child: AnimatedBuilder(
              animation: _scale,
              builder: (BuildContext context, Widget? child) {
                return Transform.scale(
                  scale: _scale.value,
                  child: child,
                );
              },
              child: SizedBox(
                width: side,
                height: side,
                child: Image.asset(
                  WaitingTinPhotoLoader.assetPath,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  errorBuilder:
                      (_, Object __, StackTrace? ___) =>
                          const Icon(Icons.image_not_supported_outlined, size: 48),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
