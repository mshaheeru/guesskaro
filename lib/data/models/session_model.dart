class SessionModel {
  const SessionModel({
    required this.id,
    required this.userId,
    required this.mode,
    required this.category,
    required this.totalCards,
    required this.correctCount,
    required this.totalPoints,
    required this.xpEarned,
    required this.maxStreak,
    required this.completedAt,
  });

  final String id;
  final String userId;
  final String mode;
  final String? category;
  final int totalCards;
  final int correctCount;
  final int totalPoints;
  final int xpEarned;
  final int maxStreak;
  final DateTime completedAt;

  double get accuracy {
    if (totalCards == 0) return 0;
    return (correctCount / totalCards) * 100;
  }

  SessionModel copyWith({
    String? id,
    String? userId,
    String? mode,
    String? category,
    bool clearCategory = false,
    int? totalCards,
    int? correctCount,
    int? totalPoints,
    int? xpEarned,
    int? maxStreak,
    DateTime? completedAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mode: mode ?? this.mode,
      category: clearCategory ? null : (category ?? this.category),
      totalCards: totalCards ?? this.totalCards,
      correctCount: correctCount ?? this.correctCount,
      totalPoints: totalPoints ?? this.totalPoints,
      xpEarned: xpEarned ?? this.xpEarned,
      maxStreak: maxStreak ?? this.maxStreak,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mode: json['mode'] as String,
      category: json['category'] as String?,
      totalCards: (json['total_cards'] as num).toInt(),
      correctCount: (json['correct_count'] as num).toInt(),
      totalPoints: (json['total_points'] as num).toInt(),
      xpEarned: (json['xp_earned'] as num).toInt(),
      maxStreak: (json['max_streak'] as num).toInt(),
      completedAt: DateTime.parse(json['completed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'mode': mode,
      'category': category,
      'total_cards': totalCards,
      'correct_count': correctCount,
      'total_points': totalPoints,
      'xp_earned': xpEarned,
      'max_streak': maxStreak,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}
