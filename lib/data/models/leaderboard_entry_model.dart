class LeaderboardEntryModel {
  const LeaderboardEntryModel({
    required this.userId,
    required this.displayName,
    required this.xp,
    required this.streak,
    required this.coins,
    required this.rank,
  });

  final String userId;
  final String displayName;
  /// Overall progression score — primary leaderboard sort.
  final int xp;
  final int streak;
  final int coins;
  final int rank;

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
