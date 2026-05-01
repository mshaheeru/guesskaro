import 'package:flutter/material.dart';

import 'urdu_text.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.message,
    super.key,
    this.emoji = '📭',
  });

  final String message;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 34)),
            const SizedBox(height: 10),
            UrduText(
              message,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
