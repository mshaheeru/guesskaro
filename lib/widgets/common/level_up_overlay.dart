import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'urdu_text.dart';

class LevelUpOverlay extends StatelessWidget {
  const LevelUpOverlay({
    required this.level,
    required this.levelTitle,
    required this.titleText,
    required this.continueText,
    required this.onDismiss,
    super.key,
  });

  final int level;
  final String levelTitle;
  final String titleText;
  final String continueText;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black54,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              ...List<Widget>.generate(
                10,
                (i) => Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .move(
                      begin: Offset.zero,
                      end: Offset((i - 5) * 10, (i.isEven ? -1 : 1) * 45),
                      duration: 900.ms,
                    )
                    .fadeIn(duration: 250.ms),
              ),
              Container(
                width: 320,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 52)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1)),
                    const SizedBox(height: 10),
                    Text(
                      titleText,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$level',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.amber.shade700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    UrduText(
                      levelTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: onDismiss,
                      child: Text(continueText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
