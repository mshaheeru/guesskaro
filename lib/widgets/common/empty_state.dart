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

  static bool _usesRtlScript(String text) {
    return RegExp(r'[\u0600-\u06FF\u0750-\u077F]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle? bodyStyle = Theme.of(context).textTheme.titleMedium;

    final Widget messageWidget =
        _usesRtlScript(message)
            ? UrduText(
              message,
              style: bodyStyle,
              textAlign: TextAlign.center,
            )
            : Text(
              message,
              style: bodyStyle,
              textAlign: TextAlign.center,
            );

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 34)),
            const SizedBox(height: 12),
            messageWidget,
          ],
        ),
      ),
    );
  }
}
