import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_config.dart';
import '../local/local_player_prefs.dart';
import '../models/profile_model.dart';

final Provider<LocalProfileRepository> localProfileRepositoryProvider =
    Provider<LocalProfileRepository>((Ref ref) => LocalProfileRepository());

class LocalProfileRepository {
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

  ProfileModel defaultProfile({
    required String displayName,
    int avatarIndex = 0,
    String inputMode = 'pick',
  }) {
    final DateTime now = DateTime.now();
    return ProfileModel(
      id: kLocalGuestUserId,
      displayName: displayName.isEmpty ? 'Player' : displayName,
      avatarIndex: avatarIndex.clamp(0, 99),
      xp: 0,
      level: 1,
      dayStreak: 0,
      longestStreak: 0,
      coins: 50,
      lastPlayedDate: null,
      createdAt: now,
      inputMode: inputMode,
    );
  }

  Future<ProfileModel?> loadProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(LocalPlayerPrefs.keyProfileJson);
    if (raw == null || raw.isEmpty) return null;
    try {
      return ProfileModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map<dynamic, dynamic>),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> persistProfile(ProfileModel profile) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      LocalPlayerPrefs.keyProfileJson,
      jsonEncode(profile.toJson()),
    );
  }

  Future<ProfileModel> ensureProfile({
    required String displayName,
    int avatarIndex = 0,
    String inputMode = 'pick',
  }) async {
    final ProfileModel? existing = await loadProfile();
    if (existing != null) return existing;

    final ProfileModel created =
        defaultProfile(
          displayName: displayName,
          avatarIndex: avatarIndex,
          inputMode: inputMode,
        );
    await persistProfile(created);
    return created;
  }

  Future<ProfileModel> addXpAndCoins({
    required int xp,
    required int coins,
  }) async {
    final ProfileModel? current = await loadProfile();
    if (current == null) throw Exception('Local profile missing.');
    final int newXp = current.xp + xp;
    final int newCoins = current.coins + coins;
    final int newLevel = _calculateLevel(newXp);
    final ProfileModel updated = current.copyWith(
      xp: newXp,
      coins: newCoins,
      level: newLevel,
    );
    await persistProfile(updated);
    return updated;
  }

  Future<ProfileModel> updateDayStreak() async {
    final ProfileModel? current = await loadProfile();
    if (current == null) throw Exception('Local profile missing.');

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime? lastPlayed = current.lastPlayedDate == null
        ? null
        : DateTime(
            current.lastPlayedDate!.year,
            current.lastPlayedDate!.month,
            current.lastPlayedDate!.day,
          );

    late int newStreak;
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
    final int newLongest =
        newStreak > current.longestStreak ? newStreak : current.longestStreak;

    final ProfileModel updated = current.copyWith(
      dayStreak: newStreak,
      longestStreak: newLongest,
      lastPlayedDate: today,
    );
    await persistProfile(updated);
    return updated;
  }

  Future<bool> deductCoins(int amount) async {
    final ProfileModel? current = await loadProfile();
    if (current == null) return false;
    if (current.coins < amount) return false;
    await persistProfile(current.copyWith(coins: current.coins - amount));
    return true;
  }

  Future<void> overwriteProfile(ProfileModel profile) async {
    await persistProfile(profile);
  }

  Future<ProfileModel> updateInputMode(String inputMode) async {
    final ProfileModel? current = await loadProfile();
    if (current == null) {
      throw Exception('Local profile missing.');
    }
    final ProfileModel updated = current.copyWith(inputMode: inputMode);
    await persistProfile(updated);
    return updated;
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

  /// Signs out offline guest — clears readiness + profile blob.
  Future<void> clearGuestData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(LocalPlayerPrefs.keyGuestReady);
    await prefs.remove(LocalPlayerPrefs.keyProfileJson);
  }
}
