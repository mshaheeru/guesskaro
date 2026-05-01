import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/cache_service.dart';
import '../models/phrase_model.dart';

class PhraseRepository {
  PhraseRepository(this._cacheService);

  final CacheService _cacheService;
  final SupabaseClient _client = Supabase.instance.client;

  static final RegExp _legacyIdPngPattern = RegExp(
    r'/phrase-images/[0-9a-fA-F-]{36}\.png$',
  );

  Map<String, dynamic> _normalizePhraseRow(Map<String, dynamic> row) {
    final String imageUrl = (row['image_url'] as String?)?.trim() ?? '';
    final String revealImageUrl =
        (row['reveal_image_url'] as String?)?.trim() ?? '';

    return <String, dynamic>{
      ...row,
      'image_url': imageUrl,
      'reveal_image_url': revealImageUrl,
    };
  }

  PhraseModel _normalizePhraseModel(PhraseModel phrase) {
    final String image = phrase.imageUrl.trim();
    final String reveal = phrase.revealImageUrl.trim();
    return phrase.copyWith(imageUrl: image, revealImageUrl: reveal);
  }

  Future<List<PhraseModel>> fetchAllPhrases({bool forceRemote = false}) async {
    if (forceRemote) {
      await _cacheService.markPhrasesStaleForRefetch();
    }

    final List<PhraseModel> cached = _cacheService.getCachedPhrases();
    final List<PhraseModel> normalizedCached =
        cached.map(_normalizePhraseModel).toList();
    final bool hasMissingPhotoUrls = normalizedCached.any(
      (PhraseModel phrase) => phrase.imageUrl.trim().isEmpty,
    );
    final bool hasLegacyIdPngUrls = normalizedCached.any(
      (PhraseModel phrase) => _legacyIdPngPattern.hasMatch(phrase.imageUrl.trim()),
    );
    final bool hasMissingPhotoPhraseOptions = normalizedCached.any(
      (PhraseModel phrase) => phrase.photoWrongOptions.length < 3,
    );
    if (!_cacheService.shouldRefetch() &&
        normalizedCached.isNotEmpty &&
        !hasMissingPhotoUrls &&
        !hasLegacyIdPngUrls &&
        !hasMissingPhotoPhraseOptions) {
      final bool cacheChanged = normalizedCached.any(
        (PhraseModel phrase) =>
            phrase.imageUrl !=
                cached
                    .firstWhere((PhraseModel p) => p.id == phrase.id)
                    .imageUrl ||
            phrase.revealImageUrl !=
                cached
                    .firstWhere((PhraseModel p) => p.id == phrase.id)
                    .revealImageUrl,
      );
      if (cacheChanged) {
        await _cacheService.cachePhrases(normalizedCached);
      }
      return normalizedCached;
    }

    try {
      final List<dynamic> phraseRows = await _client
          .from('phrases')
          .select()
          .eq('is_active', true)
          .order('created_at');

      final List<Map<String, dynamic>> phraseMaps = phraseRows
          .map((dynamic row) => Map<String, dynamic>.from(row as Map))
          .toList();

      if (phraseMaps.isEmpty) {
        return <PhraseModel>[];
      }

      final List<String> phraseIds = phraseMaps
          .map((Map<String, dynamic> row) => row['id'] as String)
          .toList();

      final List<dynamic> wrongRows = await _client
          .from('wrong_options')
          .select()
          .inFilter('phrase_id', phraseIds);
      final List<dynamic> photoRows = await _client
          .from('phrase_options')
          .select()
          .eq('is_correct', false)
          .inFilter('phrase_id', phraseIds);

      final Map<String, List<String>> wrongOptionsByPhraseId =
          <String, List<String>>{};
      for (final dynamic row in wrongRows) {
        final Map<String, dynamic> optionMap = Map<String, dynamic>.from(
          row as Map,
        );
        final String phraseId = optionMap['phrase_id'] as String;
        final String optionText = optionMap['option_text'] as String;
        wrongOptionsByPhraseId.putIfAbsent(phraseId, () => <String>[]).add(
          optionText,
        );
      }
      final Map<String, List<String>> photoWrongOptionsByPhraseId =
          <String, List<String>>{};
      for (final dynamic row in photoRows) {
        final Map<String, dynamic> optionMap = Map<String, dynamic>.from(
          row as Map,
        );
        final String phraseId = optionMap['phrase_id'] as String;
        final String optionText = optionMap['option_text'] as String;
        photoWrongOptionsByPhraseId.putIfAbsent(phraseId, () => <String>[]).add(
          optionText,
        );
      }

      final List<PhraseModel> phrases = phraseMaps
          .map(
            (Map<String, dynamic> row) => PhraseModel.fromJson(<String, dynamic>{
              ..._normalizePhraseRow(row),
              'wrong_options': wrongOptionsByPhraseId[row['id']] ?? <String>[],
              'photo_wrong_options':
                  photoWrongOptionsByPhraseId[row['id']] ?? <String>[],
            }),
          )
          .toList();

      await _cacheService.cachePhrases(phrases);
      return phrases;
    } on PostgrestException {
      if (normalizedCached.isNotEmpty) return normalizedCached;
      throw Exception('Phrases load failed and no cached data is available.');
    } catch (_) {
      if (normalizedCached.isNotEmpty) return normalizedCached;
      throw Exception('Unable to load phrases right now.');
    }
  }

  /// Minimal rows for warming disk cache after login (before a session exists).
  Future<List<String>> fetchSampleWarmImageUrls({
    int pool = 24,
    int pick = 5,
  }) async {
    try {
      final int cap = pool.clamp(8, 100);
      final List<dynamic> rows = await _client
          .from('phrases')
          .select('image_url')
          .eq('is_active', true)
          .limit(cap);

      final List<String> urls =
          rows
              .map(
                (dynamic r) =>
                    ((r as Map)['image_url'] as String?)?.trim() ?? '',
              )
              .where((String u) => u.isNotEmpty)
              .toList();

      urls.shuffle(Random());
      if (urls.length <= pick) {
        return urls;
      }
      return urls.take(pick).toList();
    } catch (_) {
      return <String>[];
    }
  }

  Future<List<PhraseModel>> getSessionPhrases({
    required String mode,
    String? category,
    String? difficulty,
    int count = 10,
  }) async {
    final List<PhraseModel> allPhrases = await fetchAllPhrases();
    Iterable<PhraseModel> filtered = allPhrases;

    if (category != null && category.isNotEmpty) {
      filtered = filtered.where((PhraseModel phrase) => phrase.category == category);
    }

    if (difficulty != null && difficulty.isNotEmpty) {
      filtered = filtered.where(
        (PhraseModel phrase) => phrase.difficulty == difficulty,
      );
    }

    final List<PhraseModel> session = filtered.toList()..shuffle();
    if (session.length <= count) return session;
    return session.take(count).toList();
  }
}

final Provider<PhraseRepository> phraseRepositoryProvider =
    Provider<PhraseRepository>(
      (Ref ref) => PhraseRepository(ref.read(cacheServiceProvider)),
    );
