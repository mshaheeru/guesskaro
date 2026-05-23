part of 'phrase_repository.dart';

extension PhraseRepositoryMastery on PhraseRepository {
  static const String _guestOnlyUserId = kLocalGuestUserId;

  bool _isGuestOnly(String userId) => userId == _guestOnlyUserId;

  Future<int> getMasteryLevel({
    required String userId,
    required String phraseId,
    bool recordSeen = true,
  }) async {
    UserProgressModel progress = await _loadProgress(userId, phraseId);

    if (recordSeen) {
      progress = progress.copyWith(
        timesSeen: progress.timesSeen + 1,
        lastSeenAt: DateTime.now(),
      );
      await _persistProgress(progress);
    }

    return progress.masteryLevel.clamp(0, MasteryConstants.maxLevel);
  }

  Future<Map<String, int>> getMasteryMap(String userId) async {
    if (_isGuestOnly(userId)) {
      return _cacheService.getAllCachedMasteryLevels(userId);
    }

    try {
      final List<dynamic> rows = await _client
          .from('user_progress')
          .select('phrase_id, mastery_level')
          .eq('user_id', userId);

      final Map<String, int> out = <String, int>{};
      for (final dynamic row in rows) {
        final Map<String, dynamic> m = Map<String, dynamic>.from(row as Map);
        out[m['phrase_id'] as String] = (m['mastery_level'] as int?) ?? 0;
      }
      return out;
    } catch (_) {
      return _cacheService.getAllCachedMasteryLevels(userId);
    }
  }

  Future<void> updateMastery({
    required String userId,
    required String phraseId,
    required bool wasCorrect,
  }) async {
    UserProgressModel progress = await _loadProgress(userId, phraseId);
    final DateTime now = DateTime.now();

    int level = progress.masteryLevel;
    int timesCorrect = progress.timesCorrect;

    if (wasCorrect) {
      timesCorrect++;
      if (timesCorrect >= level + 1 && level < MasteryConstants.maxLevel) {
        level++;
      }
    } else {
      level = (level - 1).clamp(0, MasteryConstants.maxLevel);
    }

    progress = progress.copyWith(
      masteryLevel: level,
      timesCorrect: timesCorrect,
      lastSeenAt: now,
    );

    await _persistProgress(progress);
  }

  Future<UserProgressModel> _loadProgress(
    String userId,
    String phraseId,
  ) async {
    final Map<String, dynamic>? cached =
        _cacheService.getCachedMasteryEntry(userId, phraseId);
    if (cached != null) {
      var model = _progressFromCache(userId, phraseId, cached);
      model = await _applyDecayIfNeeded(userId, phraseId, model);
      return model;
    }

    if (_isGuestOnly(userId)) {
      return UserProgressModel(
        userId: userId,
        phraseId: phraseId,
        lastSeenAt: DateTime.now(),
      );
    }

    try {
      final List<dynamic> rows = await _client
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('phrase_id', phraseId)
          .limit(1);

      if (rows.isEmpty) {
        return UserProgressModel(
          userId: userId,
          phraseId: phraseId,
          lastSeenAt: DateTime.now(),
        );
      }

      var model = UserProgressModel.fromJson(
        Map<String, dynamic>.from(rows.first as Map),
      );
      model = await _applyDecayIfNeeded(userId, phraseId, model);
      await _cacheProgress(model);
      return model;
    } catch (_) {
      return UserProgressModel(
        userId: userId,
        phraseId: phraseId,
        lastSeenAt: DateTime.now(),
      );
    }
  }

  Future<UserProgressModel> _applyDecayIfNeeded(
    String userId,
    String phraseId,
    UserProgressModel model,
  ) async {
    if (model.masteryLevel <= 0) return model;

    final DateTime cutoff =
        DateTime.now().subtract(MasteryConstants.decayAfter);
    if (!model.lastSeenAt.isBefore(cutoff)) return model;

    final UserProgressModel decayed = model.copyWith(
      masteryLevel: model.masteryLevel - 1,
      lastSeenAt: DateTime.now(),
    );
    await _persistProgress(decayed);
    return decayed;
  }

  UserProgressModel _progressFromCache(
    String userId,
    String phraseId,
    Map<String, dynamic> cached,
  ) {
    return UserProgressModel(
      userId: userId,
      phraseId: phraseId,
      masteryLevel: (cached['mastery_level'] as int?) ?? 0,
      lastSeenAt: DateTime.parse(
        (cached['last_seen_at'] as String?) ??
            DateTime.now().toIso8601String(),
      ),
      timesCorrect: (cached['times_correct'] as int?) ?? 0,
      timesSeen: (cached['times_seen'] as int?) ?? 0,
    );
  }

  Future<void> _cacheProgress(UserProgressModel model) async {
    await _cacheService.setCachedMasteryEntry(
      model.userId,
      model.phraseId,
      masteryLevel: model.masteryLevel,
      lastSeenAt: model.lastSeenAt,
      timesCorrect: model.timesCorrect,
      timesSeen: model.timesSeen,
    );
  }

  Future<void> _persistProgress(UserProgressModel model) async {
    await _cacheProgress(model);

    if (_isGuestOnly(model.userId)) return;

    try {
      await _client.from('user_progress').upsert(<String, dynamic>{
        'user_id': model.userId,
        'phrase_id': model.phraseId,
        'mastery_level': model.masteryLevel,
        'last_seen_at': model.lastSeenAt.toIso8601String(),
        'times_correct': model.timesCorrect,
        'times_seen': model.timesSeen,
        'photo_guess_correct': model.photoGuessCorrect,
        'photo_time_seconds': model.photoTimeSeconds,
        'photo_points_earned': model.photoPointsEarned,
        'meaning_guess_correct': model.meaningGuessCorrect,
        'meaning_time_seconds': model.meaningTimeSeconds,
        'meaning_points_earned': model.meaningPointsEarned,
        'total_points_earned': model.totalPointsEarned,
        'played_at': model.lastSeenAt.toIso8601String(),
      }, onConflict: 'user_id,phrase_id');
    } catch (_) {
      // Offline — Hive cache is enough until next session save.
    }
  }

  /// Mastery fields for session-end merge (does not overwrite if missing).
  Future<Map<String, dynamic>?> getMasteryFieldsForPhrase({
    required String userId,
    required String phraseId,
  }) async {
    final UserProgressModel p = await _loadProgress(userId, phraseId);
    return <String, dynamic>{
      'mastery_level': p.masteryLevel,
      'last_seen_at': p.lastSeenAt.toIso8601String(),
      'times_correct': p.timesCorrect,
      'times_seen': p.timesSeen,
    };
  }
}
