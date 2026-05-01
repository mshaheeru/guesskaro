import 'package:flutter/material.dart';

import 'urdu_text.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.message,
    super.key,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 42, color: Colors.orange.shade800),
            const SizedBox(height: 10),
            UrduText(
              message,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onRetry,
                child: const UrduText('دوبارہ کوشش کریں'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
