class ScoringConstants {
  const ScoringConstants._();

  static const int quickPlayDurationSeconds = 20;
  static const int speedRoundDurationSeconds = 10;

  /// Meaning-quiz stage timers (photo stage uses values above).
  static const int meaningQuickPlaySeconds = 10;
  static const int meaningSpeedSeconds = 8;

  static const String modeQuickPlay = 'quick_play';
  static const String modeSpeedRound = 'speed_round';

  /// Legacy sessions may still persist `learn` — treated as quick play.
  static String sanitizeGameMode(String mode) =>
      mode == 'learn' ? modeQuickPlay : mode;

  /// Photo round duration for the given session mode.
  static int photoDurationSecondsForMode(String mode) {
    switch (sanitizeGameMode(mode)) {
      case modeSpeedRound:
        return speedRoundDurationSeconds;
      case modeQuickPlay:
      default:
        return quickPlayDurationSeconds;
    }
  }

  /// Meaning-round timer length for the active mode.
  static int meaningDurationSecondsForMode(String mode) {
    switch (sanitizeGameMode(mode)) {
      case modeSpeedRound:
        return meaningSpeedSeconds;
      case modeQuickPlay:
      default:
        return meaningQuickPlaySeconds;
    }
  }

  static const int eliminateHintCost = 10;
  static const int freezeHintCost = 15;
  static const int freezeDurationSeconds = 5;

  static const int xpPerCorrect = 10;
  static const int xpPerCardCompleted = 2;
  static const int xpPerfectSessionBonus = 50;
  static const int xpDailyGoalBonus = 25;

  static const int coinsPerCorrect = 5;
  static const int startingCoins = 50;

  static int calculatePoints(int secondsRemaining, bool isCorrect) {
    if (!isCorrect) return 0;
    if (secondsRemaining >= 12) return 500;
    if (secondsRemaining >= 9) return 400;
    if (secondsRemaining >= 6) return 300;
    if (secondsRemaining >= 3) return 200;
    return 100;
  }

  static double calculateStreakMultiplier(int streak) {
    if (streak >= 8) return 3.0;
    if (streak >= 5) return 2.0;
    if (streak >= 3) return 1.5;
    return 1.0;
  }

  static String getStreakLabel(int streak, {bool isEnglish = false}) {
    if (isEnglish) {
      if (streak >= 8) return '👑 Unstoppable master';
      if (streak >= 5) return '⚡ On fire';
      if (streak >= 3) return '🔥 Great streak';
      return '';
    }
    if (streak >= 8) return '👑 استادوں کا استاد';
    if (streak >= 5) return '⚡ ناقابلِ روک';
    if (streak >= 3) return '🔥 آگ لگ گئی';
    return '';
  }

  static int applyStreakMultiplier(int basePoints, int streak) {
    final double multiplier = calculateStreakMultiplier(streak);
    return (basePoints * multiplier).round();
  }

  static int calculateSessionXp({
    required int correctCount,
    required int totalCards,
    required bool dailyGoalHit,
  }) {
    int total = 0;
    total += correctCount * xpPerCorrect;
    total += totalCards * xpPerCardCompleted;

    if (totalCards > 0 && correctCount == totalCards) {
      total += xpPerfectSessionBonus;
    }
    if (dailyGoalHit) {
      total += xpDailyGoalBonus;
    }
    return total;
  }
}
