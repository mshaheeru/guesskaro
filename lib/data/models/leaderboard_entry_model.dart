class LeaderboardEntryModel {
  const LeaderboardEntryModel({
    required this.userId,
    required this.displayName,
    required this.streak,
    required this.coins,
    required this.rank,
  });

  final String userId;
  final String displayName;
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
      streak: (row['longest_streak'] as num?)?.toInt() ?? 0,
      coins: (row['coins'] as num?)?.toInt() ?? 0,
      rank: rank,
    );
  }
}
