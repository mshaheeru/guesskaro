import 'package:flutter/material.dart';

import '../../core/constants/app_text_styles.dart';
import '../common/urdu_text.dart';

/// Reveal card rendered locally to avoid network image latency.
class RevealImageCard extends StatelessWidget {
  const RevealImageCard({
    super.key,
    required this.urduPhrase,
    this.aspectRatio = 4 / 3,
    this.radius = 16,
  });

  static const String _backgroundAssetPath = 'assets/images/reveal_bg.png';

  final String urduPhrase;
  final double aspectRatio;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _backgroundAssetPath,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Color(0xFFF4E7D8), Color(0xFFEAD7C0)],
                    ),
                  ),
                );
              },
            ),
            Align(
              alignment: const Alignment(0, 0.70),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: UrduText(
                  urduPhrase,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.urdu28Bold.copyWith(
                    color: const Color(0xFF4E342E),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
