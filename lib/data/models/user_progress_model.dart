class UserProgressModel {
  const UserProgressModel({
    required this.userId,
    required this.phraseId,
    this.masteryLevel = 0,
    required this.lastSeenAt,
    this.timesCorrect = 0,
    this.timesSeen = 0,
    this.photoGuessCorrect = false,
    this.photoTimeSeconds = 0,
    this.photoPointsEarned = 0,
    this.meaningGuessCorrect = false,
    this.meaningTimeSeconds = 0,
    this.meaningPointsEarned = 0,
    this.totalPointsEarned = 0,
  });

  final String userId;
  final String phraseId;
  final int masteryLevel;
  final DateTime lastSeenAt;
  final int timesCorrect;
  final int timesSeen;
  final bool photoGuessCorrect;
  final int photoTimeSeconds;
  final int photoPointsEarned;
  final bool meaningGuessCorrect;
  final int meaningTimeSeconds;
  final int meaningPointsEarned;
  final int totalPointsEarned;

  UserProgressModel copyWith({
    String? userId,
    String? phraseId,
    int? masteryLevel,
    DateTime? lastSeenAt,
    int? timesCorrect,
    int? timesSeen,
    bool? photoGuessCorrect,
    int? photoTimeSeconds,
    int? photoPointsEarned,
    bool? meaningGuessCorrect,
    int? meaningTimeSeconds,
    int? meaningPointsEarned,
    int? totalPointsEarned,
  }) {
    return UserProgressModel(
      userId: userId ?? this.userId,
      phraseId: phraseId ?? this.phraseId,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      timesCorrect: timesCorrect ?? this.timesCorrect,
      timesSeen: timesSeen ?? this.timesSeen,
      photoGuessCorrect: photoGuessCorrect ?? this.photoGuessCorrect,
      photoTimeSeconds: photoTimeSeconds ?? this.photoTimeSeconds,
      photoPointsEarned: photoPointsEarned ?? this.photoPointsEarned,
      meaningGuessCorrect: meaningGuessCorrect ?? this.meaningGuessCorrect,
      meaningTimeSeconds: meaningTimeSeconds ?? this.meaningTimeSeconds,
      meaningPointsEarned: meaningPointsEarned ?? this.meaningPointsEarned,
      totalPointsEarned: totalPointsEarned ?? this.totalPointsEarned,
    );
  }

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      userId: json['user_id'] as String,
      phraseId: json['phrase_id'] as String,
      masteryLevel: (json['mastery_level'] as int?) ?? 0,
      lastSeenAt: DateTime.parse(
        (json['last_seen_at'] as String?) ??
            DateTime.now().toIso8601String(),
      ),
      timesCorrect: (json['times_correct'] as int?) ?? 0,
      timesSeen: (json['times_seen'] as int?) ?? 0,
      photoGuessCorrect: json['photo_guess_correct'] as bool? ?? false,
      photoTimeSeconds: json['photo_time_seconds'] as int? ?? 0,
      photoPointsEarned: json['photo_points_earned'] as int? ?? 0,
      meaningGuessCorrect: json['meaning_guess_correct'] as bool? ?? false,
      meaningTimeSeconds: json['meaning_time_seconds'] as int? ?? 0,
      meaningPointsEarned: json['meaning_points_earned'] as int? ?? 0,
      totalPointsEarned: json['total_points_earned'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'user_id': userId,
      'phrase_id': phraseId,
      'mastery_level': masteryLevel,
      'last_seen_at': lastSeenAt.toIso8601String(),
      'times_correct': timesCorrect,
      'times_seen': timesSeen,
      'photo_guess_correct': photoGuessCorrect,
      'photo_time_seconds': photoTimeSeconds,
      'photo_points_earned': photoPointsEarned,
      'meaning_guess_correct': meaningGuessCorrect,
      'meaning_time_seconds': meaningTimeSeconds,
      'meaning_points_earned': meaningPointsEarned,
      'total_points_earned': totalPointsEarned,
    };
  }
}
