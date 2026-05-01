import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/phrase_model.dart';

class CacheService {
  static const String _phrasesBoxName = 'phrases_cache_box';
  static const String _metaBoxName = 'app_meta_box';
  static const String _lastPhraseSyncKey = 'last_phrase_sync';
  static const String _onboardingSeenKey = 'has_seen_onboarding';

  late Box<dynamic> _phrasesBox;
  late Box<dynamic> _metaBox;

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
    final String? lastSync = _metaBox.get(_lastPhraseSyncKey) as String?;
    if (lastSync == null) return true;

    final DateTime parsed = DateTime.parse(lastSync);
    return DateTime.now().difference(parsed).inHours > 24;
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
  }

  /// Drops cached phrases only — keeps onboarding / guest prefs in [SharedPreferences].
  Future<void> clearPhraseCacheOnly() async {
    await _phrasesBox.clear();
  }
}

/// Resolved to the Hive-opened singleton from `main()` via [ProviderScope.overrides].
/// Do **not** use `CacheService()` elsewhere — always call [init] exactly once before use.
final Provider<CacheService> cacheServiceProvider = Provider<CacheService>(
  (Ref ref) => CacheService(),
);
