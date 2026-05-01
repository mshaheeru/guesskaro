import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/game_provider.dart';

/// Preloads upcoming phrase photos into the Flutter image cache.
class PrefetchNextPhraseImages extends ConsumerWidget {
  const PrefetchNextPhraseImages({super.key});

  static final Set<String> _alreadyPrefetched = <String>{};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState game = ref.watch(gameNotifierProvider);

    if (game.phrases.isEmpty) return const SizedBox.shrink();

    final int nextIndex = game.currentIndex + 1;
    if (nextIndex < 0 || nextIndex >= game.phrases.length) {
      return const SizedBox.shrink();
    }

    final String nextImageUrl = game.phrases[nextIndex].imageUrl.trim();
    if (nextImageUrl.isEmpty || _alreadyPrefetched.contains(nextImageUrl)) {
      return const SizedBox.shrink();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted || _alreadyPrefetched.contains(nextImageUrl)) return;
      _alreadyPrefetched.add(nextImageUrl);
      precacheImage(
        NetworkImage(nextImageUrl),
        context,
        onError: (_, _) {
          // Keep gameplay smooth even when a URL is stale or missing in storage.
        },
      );
    });

    return const SizedBox.shrink();
  }
}
