import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Visual theme for a story picker card (emoji + accent).
class StoryIconTheme {
  const StoryIconTheme({
    required this.key,
    required this.emoji,
    required this.accentColor,
  });

  final String key;
  final String emoji;
  final Color accentColor;

  static const List<String> allowedKeys = <String>[
    'fire',
    'flower',
    'masks',
    'book',
    'star',
    'heart',
    'lightning',
    'moon',
    'sun',
    'handshake',
    'question',
  ];

  static StoryIconTheme forKey(String? rawKey) {
    switch (rawKey?.trim().toLowerCase()) {
      case 'fire':
        return StoryIconTheme(
          key: 'fire',
          emoji: '🔥',
          accentColor: AppColors.modeQuick,
        );
      case 'flower':
        return StoryIconTheme(
          key: 'flower',
          emoji: '🌼',
          accentColor: AppColors.modeSpeed,
        );
      case 'masks':
        return StoryIconTheme(
          key: 'masks',
          emoji: '🎭',
          accentColor: AppColors.purple,
        );
      case 'star':
        return StoryIconTheme(
          key: 'star',
          emoji: '⭐',
          accentColor: AppColors.marigold,
        );
      case 'heart':
        return StoryIconTheme(
          key: 'heart',
          emoji: '❤️',
          accentColor: AppColors.tomato,
        );
      case 'lightning':
        return StoryIconTheme(
          key: 'lightning',
          emoji: '⚡',
          accentColor: AppColors.modeSpeed,
        );
      case 'moon':
        return StoryIconTheme(
          key: 'moon',
          emoji: '🌙',
          accentColor: AppColors.purple,
        );
      case 'sun':
        return StoryIconTheme(
          key: 'sun',
          emoji: '☀️',
          accentColor: AppColors.marigold,
        );
      case 'handshake':
        return StoryIconTheme(
          key: 'handshake',
          emoji: '🤝',
          accentColor: AppColors.teal,
        );
      case 'question':
        return StoryIconTheme(
          key: 'question',
          emoji: '❓',
          accentColor: AppColors.modeCategory,
        );
      case 'book':
      default:
        return StoryIconTheme(
          key: 'book',
          emoji: '📖',
          accentColor: AppColors.teal,
        );
    }
  }
}
