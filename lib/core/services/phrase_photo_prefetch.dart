import 'dart:developer' as developer;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';

import '../../data/models/phrase_model.dart';
import '../../data/repositories/phrase_repository.dart';
import 'phrase_image_disk_cache.dart';

/// Phrase scene images ([PhraseModel.imageUrl]): disk prefetch + eviction for current session slice.
///
/// Post-auth warmup uses disk only ([PhraseRepository.fetchSampleWarmImageUrls]); session logic
/// tracks URLs to evict from Dart [ImageCache] when the sliding window moves (disk entries stay for reuse).
class PhrasePhotoPrefetch {
  PhrasePhotoPrefetch._();

  static const int windowSize = 5;
  static const int concurrency = 2;

  static final Set<String> _sessionTracked = <String>{};

  /// After login / guest session attach — does not block game; failures ignored.
  static Future<void> prefetchAfterAuthSignIn(PhraseRepository repo) async {
    try {
      final List<String> urls = await repo.fetchSampleWarmImageUrls(pick: 5);
      await _warmDiskOnly(urls, trackForSessionRemoval: false);
    } catch (e, st) {
      developer.log(
        'auth phrase warm skipped',
        name: 'PhrasePhotoPrefetch',
        error: e,
        stackTrace: st,
      );
    }
  }

  static String _url(PhraseModel p) => p.imageUrl.trim();

  static Iterable<String> _urlsForRange(
    List<PhraseModel> phrases,
    int start,
    int endExclusive,
  ) sync* {
    for (int i = start; i < endExclusive && i < phrases.length; i++) {
      final String u = _url(phrases[i]);
      if (u.isNotEmpty) yield u;
    }
  }

  /// Flush decoded bitmaps for URLs we prefetched during this session (disk cache kept).
  static void clearSessionTracked() {
    for (final String u in List<String>.from(_sessionTracked)) {
      _evictDecoded(u);
    }
    _sessionTracked.clear();
  }

  static void _evictDecoded(String raw) {
    final String u = raw.trim();
    if (u.isEmpty) return;
    final ImageProvider<Object> provider = CachedNetworkImageProvider(
      u,
      cacheManager: PhraseImageDiskCache.manager,
    );
    PaintingBinding.instance.imageCache.evict(provider);
  }

  static Future<void> prefetchNewSession(List<PhraseModel> phrases) async {
    clearSessionTracked();
    if (phrases.isEmpty) return;
    final int n = phrases.length < windowSize ? phrases.length : windowSize;
    final List<String> batch = _urlsForRange(phrases, 0, n).toSet().toList();
    await _warmDiskOnly(batch, trackForSessionRemoval: true);
  }

  static Future<void> onCardAdvanced({
    required int previousIndex,
    required List<PhraseModel> phrases,
    required int newCurrentIndex,
  }) async {
    if (previousIndex >= 0 && previousIndex < phrases.length) {
      final String gone = _url(phrases[previousIndex]);
      if (gone.isNotEmpty) {
        _evictDecoded(gone);
        _sessionTracked.remove(gone);
      }
    }
    final int ahead = newCurrentIndex + windowSize - 1;
    if (ahead >= 0 && ahead < phrases.length) {
      final List<String> nextBatch =
          _urlsForRange(phrases, ahead, ahead + 1).toSet().toList();
      await _warmDiskOnly(nextBatch, trackForSessionRemoval: true);
    }
  }

  static Future<void> _warmDiskOnly(
    Iterable<String> urls, {
    required bool trackForSessionRemoval,
  }) async {
    final List<String> list =
        urls.map((String e) => e.trim()).where((String u) => u.isNotEmpty).toList();
    if (list.isEmpty) return;
    final List<String> unique = list.toSet().toList();
    for (int i = 0; i < unique.length; i += concurrency) {
      final Iterable<String> chunk = unique.skip(i).take(concurrency);
      await Future.wait(
        chunk.map((String u) => PhraseImageDiskCache.manager.getSingleFile(u)),
      );
      if (trackForSessionRemoval) {
        _sessionTracked.addAll(chunk);
      }
    }
  }
}
