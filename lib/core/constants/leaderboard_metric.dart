/// Leaderboard tab sort keys.
enum LeaderboardMetric {
  /// Best in-session streak ([ProfileModel.longestStreak]).
  sessionStreak,

  /// Calendar-day play streak ([ProfileModel.dayStreak]).
  dailyStreak,

  /// Lifetime XP ([ProfileModel.xp]).
  totalScore,
}
