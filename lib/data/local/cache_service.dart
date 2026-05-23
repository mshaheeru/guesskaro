import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_config.dart';
import '../models/phrase_model.dart';

class CacheService {
  static const String _phrasesBoxName = 'phrases_cache_box';
  static const String _metaBoxName = 'app_meta_box';
  static const String _lastPhraseSyncKey = 'last_phrase_sync';
  static const String _onboardingSeenKey = 'has_seen_onboarding';
  static const String _masteryBoxName = 'mastery_cache_box';

  late Box<dynamic> _phrasesBox;
  late Box<dynamic> _metaBox;
  late Box<dynamic> _masteryBox;

  static String masteryKey(String userId, String phraseId) =>
      'mastery_${userId}_$phraseId';

  Future<void> init() async {
    if (Hive.isBoxOpen(_phrasesBoxName)) {
      _phrasesBox = Hive.box<dynamic>(_phrasesBoxName);
    } else {
      _phrasesBox = await Hive.openBox<dynamic>(_phrasesBoxName);
    }

    if (Hive.isBoxOpen(_metaBoxName)) {
      _metaBox = Hive.box<dynamic>(_metaBoxName);
    } else {
      _metaBox = await Hive.openBox<dynamic>(_metaBoxName);
    }

    if (Hive.isBoxOpen(_masteryBoxName)) {
      _masteryBox = Hive.box<dynamic>(_masteryBoxName);
    } else {
      _masteryBox = await Hive.openBox<dynamic>(_masteryBoxName);
    }
  }

  Map<String, dynamic>? getCachedMasteryEntry(String userId, String phraseId) {
    final dynamic v = _masteryBox.get(masteryKey(userId, phraseId));
    if (v is Map) {
      return Map<String, dynamic>.from(v);
    }
    if (v is int) {
      return <String, dynamic>{
        'mastery_level': v,
        'last_seen_at': DateTime.now().toIso8601String(),
        'times_correct': 0,
        'times_seen': 0,
      };
    }
    return null;
  }

  int? getCachedMasteryLevel(String userId, String phraseId) {
    final Map<String, dynamic>? e = getCachedMasteryEntry(userId, phraseId);
    if (e == null) return null;
    return e['mastery_level'] as int?;
  }

  Future<void> setCachedMasteryEntry(
    String userId,
    String phraseId, {
    required int masteryLevel,
    required DateTime lastSeenAt,
    required int timesCorrect,
    required int timesSeen,
  }) async {
    await _masteryBox.put(masteryKey(userId, phraseId), <String, dynamic>{
      'mastery_level': masteryLevel,
      'last_seen_at': lastSeenAt.toIso8601String(),
      'times_correct': timesCorrect,
      'times_seen': timesSeen,
    });
  }

  Map<String, int> getAllCachedMasteryLevels(String userId) {
    final String prefix = 'mastery_${userId}_';
    final Map<String, int> out = <String, int>{};
    for (final dynamic key in _masteryBox.keys) {
      if (key is! String || !key.startsWith(prefix)) continue;
      final Map<String, dynamic>? e = getCachedMasteryEntry(
        userId,
        key.substring(prefix.length),
      );
      if (e == null) continue;
      out[key.substring(prefix.length)] = (e['mastery_level'] as int?) ?? 0;
    }
    return out;
  }

  Future<void> clearMasteryForUser(String userId) async {
    final String prefix = 'mastery_${userId}_';
    final List<dynamic> toRemove = _masteryBox.keys
        .where((dynamic k) => k is String && k.startsWith(prefix))
        .toList();
    for (final dynamic k in toRemove) {
      await _masteryBox.delete(k);
    }
  }

  Future<void> cachePhrases(List<PhraseModel> phrases) async {
    final List<Map<String, dynamic>> serialized = phrases
        .map((PhraseModel phrase) => phrase.toJson())
        .toList();
    await _phrasesBox.put('phrases', serialized);
    await _metaBox.put(_lastPhraseSyncKey, DateTime.now().toIso8601String());
  }

  List<PhraseModel> getCachedPhrases() {
    final dynamic raw = _phrasesBox.get('phrases');
    if (raw == null || raw is! List) {
      return <PhraseModel>[];
    }

    return raw
        .whereType<Map>()
        .map(
          (Map<dynamic, dynamic> json) => PhraseModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  bool shouldRefetch() {
    if (kPhraseCacheTtlHours <= 0) return true;

    final String? lastSync = _metaBox.get(_lastPhraseSyncKey) as String?;
    if (lastSync == null) return true;

    final DateTime parsed = DateTime.parse(lastSync);
    final Duration ttl = Duration(hours: kPhraseCacheTtlHours);
    return DateTime.now().difference(parsed) >= ttl;
  }

  /// Next [fetchAllPhrases] skips fast path and pulls from Supabase (keeps Hive copy for fallback on error).
  Future<void> markPhrasesStaleForRefetch() async {
    await _metaBox.delete(_lastPhraseSyncKey);
  }

  Future<void> saveOnboardingSeen() async {
    await _metaBox.put(_onboardingSeenKey, true);
  }

  bool hasSeenOnboarding() {
    return (_metaBox.get(_onboardingSeenKey) as bool?) ?? false;
  }

  Future<void> clearAll() async {
    await _phrasesBox.clear();
    await _metaBox.clear();
    await _masteryBox.clear();
  }

  /// Drops cached phrases only — keeps onboarding / guest prefs in [SharedPreferences].
  Future<void> clearPhraseCacheOnly() async {
    await _phrasesBox.clear();
    await _metaBox.delete(_lastPhraseSyncKey);
  }
}

/// Resolved to the Hive-opened singleton from `main()` via [ProviderScope.overrides].
/// Do **not** use `CacheService()` elsewhere — always call [init] exactly once before use.
final Provider<CacheService> cacheServiceProvider = Provider<CacheService>(
  (Ref ref) => CacheService(),
);
