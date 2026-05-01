import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/phrase_photo_prefetch.dart';
import '../../data/models/phrase_model.dart';
import '../../data/repositories/phrase_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/game_provider.dart';

/// Listens to [gameNotifierProvider] and keeps a sliding window of phrase photos warm.
class PhrasePhotoPrefetchHost extends ConsumerStatefulWidget {
  const PhrasePhotoPrefetchHost({super.key});

  @override
  ConsumerState<PhrasePhotoPrefetchHost> createState() =>
      _PhrasePhotoPrefetchHostState();
}

class _PhrasePhotoPrefetchHostState extends ConsumerState<PhrasePhotoPrefetchHost> {
  String? _sessionFingerprint;
  String? _authWarmUserId;

  void _schedule(void Function() fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      fn();
    });
  }

  void _handle(GameState? previous, GameState next) {
    if (next.phrases.isEmpty) {
      _sessionFingerprint = null;
      PhrasePhotoPrefetch.clearSessionTracked();
      return;
    }

    if (next.phase == GamePhase.sessionComplete) {
      _sessionFingerprint = null;
      PhrasePhotoPrefetch.clearSessionTracked();
      return;
    }

    if (next.phase == GamePhase.loadingPhrases) {
      return;
    }

    final String fp = next.phrases.map((PhraseModel p) => p.id).join('|');

    if (fp != _sessionFingerprint) {
      _sessionFingerprint = fp;
      unawaited(PhrasePhotoPrefetch.prefetchNewSession(next.phrases));
      return;
    }

    if (previous != null && previous.currentIndex != next.currentIndex) {
      unawaited(
        PhrasePhotoPrefetch.onCardAdvanced(
          previousIndex: previous.currentIndex,
          phrases: next.phrases,
          newCurrentIndex: next.currentIndex,
        ),
      );
    }
  }

  void _warmAuthPhotos(User? next) {
    if (next == null) {
      _authWarmUserId = null;
      return;
    }
    if (_authWarmUserId == next.id) {
      return;
    }
    _authWarmUserId = next.id;
    final PhraseRepository repo = ref.read(phraseRepositoryProvider);
    unawaited(PhrasePhotoPrefetch.prefetchAfterAuthSignIn(repo));
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual<GameState>(gameNotifierProvider, (GameState? p, GameState n) {
      _schedule(() => _handle(p, n));
    });
    ref.listenManual<User?>(currentUserProvider, (User? p, User? n) {
      _schedule(() => _warmAuthPhotos(n));
    });
    _schedule(() {
      _handle(null, ref.read(gameNotifierProvider));
      _warmAuthPhotos(ref.read(currentUserProvider));
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
