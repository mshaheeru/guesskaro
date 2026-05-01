import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_config.dart';
import '../models/session_model.dart';

class SessionRepository {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _pendingBoxName = 'pending_sessions_box';

  /// Hive box for offline guest sessions (no Supabase user row).
  static const String _localSessionsBoxName = 'local_guest_sessions_v1';

  Future<void> saveSession(SessionModel session) async {
    await _client.from('sessions').insert(session.toJson());
  }

  Future<void> saveUserProgress({
    required String userId,
    required String phraseId,
    required bool photoGuessCorrect,
    required int photoTimeSeconds,
    required int photoPointsEarned,
    required bool meaningGuessCorrect,
    required int meaningTimeSeconds,
    required int meaningPointsEarned,
    required int totalPointsEarned,
  }) async {
    await _client.from('user_progress').upsert(<String, dynamic>{
      'user_id': userId,
      'phrase_id': phraseId,
      'photo_guess_correct': photoGuessCorrect,
      'photo_time_seconds': photoTimeSeconds,
      'photo_points_earned': photoPointsEarned,
      'meaning_guess_correct': meaningGuessCorrect,
      'meaning_time_seconds': meaningTimeSeconds,
      'meaning_points_earned': meaningPointsEarned,
      'total_points_earned': totalPointsEarned,
      'played_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,phrase_id');
  }

  Future<void> saveFullSession({
    required SessionModel session,
    required List<Map<String, dynamic>> phraseResults,
  }) async {
    if (!kAuthEnabled) {
      await _persistLocalGuestSession(
        session: session,
        phraseResults: phraseResults,
      );
      return;
    }

    final String userId =
        phraseResults.isNotEmpty ? phraseResults.first['userId'] as String : '';

    if (userId.isEmpty || userId == kLocalGuestUserId) {
      await _persistLocalGuestSession(
        session: session,
        phraseResults: phraseResults,
      );
      return;
    }

    try {
      await saveSession(session);
      await Future.wait(
        phraseResults.map(
          (Map<String, dynamic> row) => saveUserProgress(
            userId: row['userId'] as String,
            phraseId: row['phraseId'] as String,
            photoGuessCorrect: row['photoGuessCorrect'] as bool,
            photoTimeSeconds: row['photoTimeSeconds'] as int,
            photoPointsEarned: row['photoPointsEarned'] as int,
            meaningGuessCorrect: row['meaningGuessCorrect'] as bool,
            meaningTimeSeconds: row['meaningTimeSeconds'] as int,
            meaningPointsEarned: row['meaningPointsEarned'] as int,
            totalPointsEarned: row['totalPointsEarned'] as int,
          ),
        ),
      );
    } catch (_) {
      await _enqueuePendingSession(
        session: session,
        phraseResults: phraseResults,
      );
    }
  }

  Future<void> _enqueuePendingSession({
    required SessionModel session,
    required List<Map<String, dynamic>> phraseResults,
  }) async {
    final Box<dynamic> box = await _pendingBox();
    await box.add(<String, dynamic>{
      'session': session.toJson(),
      'phrase_results': phraseResults,
      'queued_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Box<dynamic>> _pendingBox() async {
    if (Hive.isBoxOpen(_pendingBoxName)) {
      return Hive.box<dynamic>(_pendingBoxName);
    }
    return Hive.openBox<dynamic>(_pendingBoxName);
  }

  Future<void> retryPendingSessions() async {
    if (!kAuthEnabled) return;

    final Box<dynamic> box = await _pendingBox();
    final List<dynamic> entries = box.values.toList();
    final List<dynamic> keys = box.keys.toList();

    for (int i = 0; i < entries.length; i++) {
      final dynamic raw = entries[i];
      final dynamic key = keys[i];
      if (raw is! Map) continue;
      try {
        final Map<String, dynamic> row = Map<String, dynamic>.from(raw);
        final SessionModel session = SessionModel.fromJson(
          Map<String, dynamic>.from(row['session'] as Map),
        );
        final List<Map<String, dynamic>> phraseResults =
            (row['phrase_results'] as List<dynamic>)
                .map((dynamic e) => Map<String, dynamic>.from(e as Map))
                .toList();

        await saveSession(session);
        await Future.wait(
          phraseResults.map(
            (Map<String, dynamic> pr) => saveUserProgress(
              userId: pr['userId'] as String,
              phraseId: pr['phraseId'] as String,
              photoGuessCorrect: pr['photoGuessCorrect'] as bool,
              photoTimeSeconds: pr['photoTimeSeconds'] as int,
              photoPointsEarned: pr['photoPointsEarned'] as int,
              meaningGuessCorrect: pr['meaningGuessCorrect'] as bool,
              meaningTimeSeconds: pr['meaningTimeSeconds'] as int,
              meaningPointsEarned: pr['meaningPointsEarned'] as int,
              totalPointsEarned: pr['totalPointsEarned'] as int,
            ),
          ),
        );
        await box.delete(key);
      } catch (_) {
        // Keep queued for next launch retry.
      }
    }
  }

  Future<List<SessionModel>> getRecentSessions({
    required String userId,
    int limit = 5,
  }) async {
    if (userId == kLocalGuestUserId) {
      return _localRecentSessions(limit: limit);
    }

    final List<dynamic> rows = await _client
        .from('sessions')
        .select()
        .eq('user_id', userId)
        .order('completed_at', ascending: false)
        .limit(limit);

    return rows
        .map(
          (dynamic row) =>
              SessionModel.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<int> getTodayCardCount(String userId) async {
    if (userId == kLocalGuestUserId) {
      return _localCardsPlayedTodaySoFar();
    }

    final DateTime now = DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day);
    final List<dynamic> rows = await _client
        .from('user_progress')
        .select('id')
        .eq('user_id', userId)
        .gte('played_at', startOfDay.toIso8601String());
    return rows.length;
  }

  Future<Box<dynamic>> _localBox() async {
    if (Hive.isBoxOpen(_localSessionsBoxName)) {
      return Hive.box<dynamic>(_localSessionsBoxName);
    }
    return Hive.openBox<dynamic>(_localSessionsBoxName);
  }

  String _todayKey(DateTime dt) =>
      '${dt.year}_${dt.month.toString().padLeft(2, '0')}_${dt.day.toString().padLeft(2, '0')}';

  Future<int> _localCardsPlayedTodaySoFar() async {
    final Box<dynamic> box = await _localBox();
    final DateTime today = DateTime.now();
    final String key = 'cards_${_todayKey(today)}';
    final dynamic n = box.get(key);
    if (n == null || n is! int) return 0;
    return n;
  }

  Future<List<SessionModel>> _localRecentSessions({required int limit}) async {
    final Box<dynamic> box = await _localBox();
    final dynamic raw = box.get('recent_sessions_list');
    if (raw == null || raw is! List) return <SessionModel>[];
    final List<SessionModel> out = raw
        .whereType<Map>()
        .map(
          (Map<dynamic, dynamic> m) =>
              SessionModel.fromJson(Map<String, dynamic>.from(m)),
        )
        .toList(growable: false);
    if (out.length <= limit) return out;
    return out.take(limit).toList();
  }

  Future<void> _persistLocalGuestSession({
    required SessionModel session,
    required List<Map<String, dynamic>> phraseResults,
  }) async {
    final Box<dynamic> box = await _localBox();

    final DateTime today = DateTime.now();
    final String dayKey = 'cards_${_todayKey(today)}';
    final int played = phraseResults.length;
    final int prev = (box.get(dayKey) as int?) ?? 0;
    await box.put(dayKey, prev + played);

    final dynamic listRaw = box.get('recent_sessions_list');
    final List<Map<String, dynamic>> next =
        listRaw == null || listRaw is! List
            ? <Map<String, dynamic>>[]
            : listRaw.whereType<Map>().map(Map<String, dynamic>.from).toList();
    next.insert(0, session.toJson());
    while (next.length > 50) {
      next.removeLast();
    }
    await box.put('recent_sessions_list', next);
  }
}

final Provider<SessionRepository> sessionRepositoryProvider =
    Provider<SessionRepository>((Ref ref) => SessionRepository());
