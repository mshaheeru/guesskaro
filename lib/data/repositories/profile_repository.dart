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

  Future<List<LeaderboardEntryModel>> fetchTopLeaderboard({
    int limit = 20,
  }) async {
    if (!kAuthEnabled) {
      return <LeaderboardEntryModel>[];
    }
    final List<dynamic> rows = await _client
        .from('profiles')
        .select('id, display_name, longest_streak, coins')
        .eq('show_on_leaderboard', true)
        .order('longest_streak', ascending: false)
        .order('coins', ascending: false)
        .limit(limit);
    return rows
        .asMap()
        .entries
        .map((entry) {
          return LeaderboardEntryModel.fromProfileRow(
            Map<String, dynamic>.from(entry.value as Map),
            rank: entry.key + 1,
          );
        })
        .toList(growable: false);
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
