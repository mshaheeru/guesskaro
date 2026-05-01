import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_config.dart';
import '../models/leaderboard_entry_model.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final SupabaseClient _client = Supabase.instance.client;

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

  Future<ProfileModel?> fetchProfile(String userId) async {
    final List<dynamic> rows = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .limit(1);
    if (rows.isEmpty) return null;
    return ProfileModel.fromJson(Map<String, dynamic>.from(rows.first as Map));
  }

  Future<ProfileModel> createProfile({
    required String userId,
    required String displayName,
    int avatarIndex = 0,
    String inputMode = 'pick',
    bool showOnLeaderboard = false,
  }) async {
    final List<dynamic> rows = await _client
        .from('profiles')
        .insert(<String, dynamic>{
          'id': userId,
          'display_name': displayName,
          'avatar_index': avatarIndex,
          'input_mode': inputMode,
          'show_on_leaderboard': showOnLeaderboard,
        })
        .select()
        .limit(1);
    return ProfileModel.fromJson(Map<String, dynamic>.from(rows.first as Map));
  }

  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    final List<dynamic> rows = await _client
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id)
        .select()
        .limit(1);
    return ProfileModel.fromJson(Map<String, dynamic>.from(rows.first as Map));
  }

  Future<ProfileModel> addXpAndCoins({
    required String userId,
    required int xp,
    required int coins,
  }) async {
    final ProfileModel? current = await fetchProfile(userId);
    if (current == null) {
      throw Exception('Profile not found for XP/coins update.');
    }

    final int newXp = current.xp + xp;
    final int newCoins = current.coins + coins;
    final int newLevel = _calculateLevel(newXp);

    final List<dynamic> rows = await _client
        .from('profiles')
        .update(<String, dynamic>{
          'xp': newXp,
          'coins': newCoins,
          'level': newLevel,
        })
        .eq('id', userId)
        .select()
        .limit(1);
    return ProfileModel.fromJson(Map<String, dynamic>.from(rows.first as Map));
  }

  Future<ProfileModel> updateDayStreak(String userId) async {
    final ProfileModel? current = await fetchProfile(userId);
    if (current == null) {
      throw Exception('Profile not found for day streak update.');
    }

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime? lastPlayed =
        current.lastPlayedDate == null
            ? null
            : DateTime(
              current.lastPlayedDate!.year,
              current.lastPlayedDate!.month,
              current.lastPlayedDate!.day,
            );

    int newStreak;
    int newLongest;

    if (lastPlayed == null) {
      newStreak = 1;
    } else {
      final int gapDays = today.difference(lastPlayed).inDays;
      if (gapDays == 0) {
        newStreak = current.dayStreak;
      } else if (gapDays == 1) {
        newStreak = current.dayStreak + 1;
      } else {
        newStreak = 1;
      }
    }

    newLongest =
        newStreak > current.longestStreak ? newStreak : current.longestStreak;

    final List<dynamic> rows = await _client
        .from('profiles')
        .update(<String, dynamic>{
          'day_streak': newStreak,
          'longest_streak': newLongest,
          'last_played_date': today.toIso8601String().split('T').first,
        })
        .eq('id', userId)
        .select()
        .limit(1);
    return ProfileModel.fromJson(Map<String, dynamic>.from(rows.first as Map));
  }

  Future<bool> deductCoins({
    required String userId,
    required int amount,
  }) async {
    final ProfileModel? current = await fetchProfile(userId);
    if (current == null) return false;
    if (current.coins < amount) return false;

    await _client
        .from('profiles')
        .update(<String, dynamic>{'coins': current.coins - amount})
        .eq('id', userId);
    return true;
  }

  Future<ProfileModel> updateInputMode({
    required String userId,
    required String inputMode,
  }) async {
    final List<dynamic> rows = await _client
        .from('profiles')
        .update(<String, dynamic>{'input_mode': inputMode})
        .eq('id', userId)
        .select()
        .limit(1);
    return ProfileModel.fromJson(Map<String, dynamic>.from(rows.first as Map));
  }

  static int _activityScore(DateTime? lastPlayed) =>
      lastPlayed?.millisecondsSinceEpoch ?? 0;

  /// Computes 1-based rank: higher XP first; same XP → more recently active wins.
  Future<int> leaderboardRankFor(ProfileModel profile) async {
    if (!kAuthEnabled) return 1;

    final PostgrestResponse<List<dynamic>> strictlyHigherXp = await _client
        .from('profiles')
        .select('id')
        .gt('xp', profile.xp)
        .count(CountOption.exact);
    final int higherXpBand = strictlyHigherXp.count;

    final List<dynamic> sameXpRows = await _client
        .from('profiles')
        .select('id, last_played_date')
        .eq('xp', profile.xp);

    final int myAct = _activityScore(profile.lastPlayedDate);
    int tieAhead = 0;
    for (final dynamic row in sameXpRows) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(row as Map);
      if ((map['id'] as String) == profile.id) continue;
      final DateTime? otherLast =
          map['last_played_date'] == null
              ? null
              : DateTime.tryParse(map['last_played_date'] as String);
      if (_activityScore(otherLast) > myAct) tieAhead++;
    }

    return higherXpBand + tieAhead + 1;
  }

  LeaderboardScreenData _leaderboardFromRpc(Map<String, dynamic> raw) {
    final List<dynamic> topRaw =
        raw['top'] as List<dynamic>? ?? const <dynamic>[];

    final List<LeaderboardEntryModel> top = <LeaderboardEntryModel>[];
    int index = 0;
    for (final dynamic row in topRaw) {
      index++;
      top.add(
        LeaderboardEntryModel.fromProfileRow(
          Map<String, dynamic>.from(row as Map<dynamic, dynamic>),
          rank: index,
        ),
      );
    }

    LeaderboardEntryModel? youRow;
    final dynamic youRaw = raw['you'];
    if (youRaw is Map<dynamic, dynamic>) {
      final Map<String, dynamic> ym =
          Map<String, dynamic>.from(youRaw);
      youRow = LeaderboardEntryModel(
        userId: ym['id'] as String,
        displayName:
            ((ym['display_name'] as String?) ?? '').trim().isNotEmpty
                ? ym['display_name'] as String
                : 'Player',
        xp: (ym['xp'] as num?)?.toInt() ?? 0,
        streak: (ym['longest_streak'] as num?)?.toInt() ?? 0,
        coins: (ym['coins'] as num?)?.toInt() ?? 0,
        rank: (ym['rank'] as num?)?.toInt() ?? 1,
      );
    }

    return LeaderboardScreenData(top: top, you: youRow);
  }

  /// Fallback when RPC missing / not migrated — sees only rows allowed by RLS.
  Future<LeaderboardScreenData> fetchLeaderboardScreenDataFromProfilesTable({
    String? signedInUserId,
  }) async {
    final List<LeaderboardEntryModel> top =
        await fetchTopLeaderboard(limit: 10);

    LeaderboardEntryModel? youRow;
    if (signedInUserId != null) {
      final ProfileModel? p = await fetchProfile(signedInUserId);
      if (p != null) {
        final int rank = await leaderboardRankFor(p);
        youRow = LeaderboardEntryModel(
          userId: p.id,
          displayName:
              p.displayName.trim().isNotEmpty ? p.displayName.trim() : 'Player',
          xp: p.xp,
          streak: p.longestStreak,
          coins: p.coins,
          rank: rank,
        );
      }
    }

    return LeaderboardScreenData(top: top, you: youRow);
  }

  /// Top `[limit]` globally by XP, then recent `last_played_date` among ties.
  Future<List<LeaderboardEntryModel>> fetchTopLeaderboard({int limit = 10}) async {
    if (!kAuthEnabled) return <LeaderboardEntryModel>[];
    final List<dynamic> rows = await _client
        .from('profiles')
        .select(
          'id, display_name, xp, longest_streak, coins, last_played_date',
        )
        .order('xp', ascending: false)
        .order(
          'last_played_date',
          ascending: false,
          nullsFirst: false,
        )
        .limit(limit);

    int index = 0;
    final List<LeaderboardEntryModel> out = <LeaderboardEntryModel>[];
    for (final dynamic raw in rows) {
      index++;
      out.add(
        LeaderboardEntryModel.fromProfileRow(
          Map<String, dynamic>.from(raw as Map),
          rank: index,
        ),
      );
    }
    return out;
  }

  /// Prefer [leaderboard_bundle] RPC — bypasses restrictive `profiles` RLS.
  Future<LeaderboardScreenData> fetchLeaderboardScreenData({
    String? signedInUserId,
  }) async {
    if (!kAuthEnabled) {
      return const LeaderboardScreenData(top: <LeaderboardEntryModel>[], you: null);
    }

    try {
      final dynamic raw = await _client.rpc(
        'leaderboard_bundle',
        params: <String, dynamic>{'p_user_id': signedInUserId},
      );
      if (raw is Map<String, dynamic>) {
        return _leaderboardFromRpc(raw);
      }
      if (raw is Map) {
        return _leaderboardFromRpc(Map<String, dynamic>.from(raw));
      }
    } on PostgrestException {
      // RPC missing or privileges — fall back (often only shows self under RLS).
    } catch (_) {}

    return fetchLeaderboardScreenDataFromProfilesTable(
      signedInUserId: signedInUserId,
    );
  }

  int _calculateLevel(int xp) {
    int level = 1;
    for (int i = 0; i < _levelThresholds.length; i++) {
      if (xp >= _levelThresholds[i]) {
        level = i + 1;
      } else {
        break;
      }
    }
    return level;
  }
}

final Provider<ProfileRepository> profileRepositoryProvider =
    Provider<ProfileRepository>((Ref ref) => ProfileRepository());
