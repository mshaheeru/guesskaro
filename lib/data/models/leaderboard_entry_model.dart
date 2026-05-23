import '../../core/constants/leaderboard_metric.dart';

class LeaderboardEntryModel {
  const LeaderboardEntryModel({
    required this.userId,
    required this.displayName,
    required this.xp,
    required this.streak,
    required this.dayStreak,
    required this.coins,
    required this.rank,
  });

  final String userId;
  final String displayName;
  /// Lifetime XP — total score leaderboard.
  final int xp;
  /// Best streak reached in any session ([profiles.longest_streak]).
  final int streak;
  /// Calendar-day play streak ([profiles.day_streak]).
  final int dayStreak;
  final int coins;
  final int rank;

  int scoreFor(LeaderboardMetric metric) {
    switch (metric) {
      case LeaderboardMetric.sessionStreak:
        return streak;
      case LeaderboardMetric.dailyStreak:
        return dayStreak;
      case LeaderboardMetric.totalScore:
        return xp;
    }
  }

  factory LeaderboardEntryModel.fromProfileRow(
    Map<String, dynamic> row, {
    required int rank,
  }) {
    return LeaderboardEntryModel(
      userId: row['id'] as String,
      displayName:
          (row['display_name'] as String?)?.trim().isNotEmpty == true
              ? row['display_name'] as String
              : 'Player',
      xp: (row['xp'] as num?)?.toInt() ?? 0,
      streak: (row['longest_streak'] as num?)?.toInt() ?? 0,
      dayStreak: (row['day_streak'] as num?)?.toInt() ?? 0,
      coins: (row['coins'] as num?)?.toInt() ?? 0,
      rank: rank,
    );
  }
}

/// Combined payload for leaderboard UI: global top slice + signed-in user's rank row.
class LeaderboardScreenData {
  const LeaderboardScreenData({
    required this.top,
    required this.you,
  });

  final List<LeaderboardEntryModel> top;

  /// Current user's placement (may rank below `#10` — still shown).
  final LeaderboardEntryModel? you;
}
