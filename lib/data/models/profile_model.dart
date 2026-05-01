class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.displayName,
    required this.avatarIndex,
    required this.xp,
    required this.level,
    required this.dayStreak,
    required this.longestStreak,
    required this.coins,
    required this.lastPlayedDate,
    required this.createdAt,
    this.inputMode = 'pick',
    this.showOnLeaderboard = false,
  });

  final String id;
  final String displayName;
  final int avatarIndex;
  final int xp;
  final int level;
  final int dayStreak;
  final int longestStreak;
  final int coins;
  final DateTime? lastPlayedDate;
  final DateTime createdAt;
  final String inputMode;

  /// When true, ranked on global leaderboard (Supabase profiles only).
  final bool showOnLeaderboard;

  static const List<int> _levelThresholds = <int>[
    0,
    100,
    250,
    400,
    500,
    700,
    900,
    1100,
    1300,
    1500,
    1800,
    2100,
    2500,
    3000,
    3500,
    4000,
    4500,
    5000,
    6000,
    10000,
  ];

  ProfileModel copyWith({
    String? id,
    String? displayName,
    int? avatarIndex,
    int? xp,
    int? level,
    int? dayStreak,
    int? longestStreak,
    int? coins,
    DateTime? lastPlayedDate,
    bool clearLastPlayedDate = false,
    DateTime? createdAt,
    String? inputMode,
    bool? showOnLeaderboard,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      dayStreak: dayStreak ?? this.dayStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      coins: coins ?? this.coins,
      lastPlayedDate:
          clearLastPlayedDate ? null : (lastPlayedDate ?? this.lastPlayedDate),
      createdAt: createdAt ?? this.createdAt,
      inputMode: inputMode ?? this.inputMode,
      showOnLeaderboard: showOnLeaderboard ?? this.showOnLeaderboard,
    );
  }

  String get levelTitle {
    if (level >= 30) return 'زبان کا بادشاہ';
    if (level >= 20) return 'استاد';
    if (level >= 15) return 'محاورہ ماہر';
    if (level >= 10) return 'زبان دان';
    if (level >= 5) return 'پکا شاگرد';
    return 'نیا سیکھنے والا';
  }

  int get xpForNextLevel {
    final int currentIndex = level - 1;
    if (currentIndex < 0 || currentIndex >= _levelThresholds.length - 1) {
      return 0;
    }
    final int nextThreshold = _levelThresholds[currentIndex + 1];
    final int remaining = nextThreshold - xp;
    return remaining > 0 ? remaining : 0;
  }

  /// XP progress fraction within the current level band (0–1).
  double get xpBarFractionWithinCurrentLevel {
    final int idx = level - 1;
    if (idx < 0) return 0;
    final int floor = _levelThresholds[idx];
    if (idx >= _levelThresholds.length - 1) {
      return 1;
    }
    final int ceil = _levelThresholds[idx + 1];
    final double span = (ceil - floor).toDouble();
    if (span <= 0) return 1;
    return ((xp - floor) / span).clamp(0.0, 1.0);
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      avatarIndex: (json['avatar_index'] as num?)?.toInt() ?? 0,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      dayStreak: (json['day_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      coins: (json['coins'] as num?)?.toInt() ?? 50,
      lastPlayedDate:
          json['last_played_date'] == null
              ? null
              : DateTime.parse(json['last_played_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      inputMode: (json['input_mode'] as String?) ?? 'pick',
      showOnLeaderboard: json['show_on_leaderboard'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'display_name': displayName,
      'avatar_index': avatarIndex,
      'xp': xp,
      'level': level,
      'day_streak': dayStreak,
      'longest_streak': longestStreak,
      'coins': coins,
      'last_played_date': lastPlayedDate?.toIso8601String().split('T').first,
      'created_at': createdAt.toIso8601String(),
      'input_mode': inputMode,
      'show_on_leaderboard': showOnLeaderboard,
    };
  }
}
