import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_config.dart';
import '../data/repositories/phrase_repository.dart';
import 'session_user_provider.dart';

/// Reverse mode unlocks when user has at least 3 phrases at mastery level 3+.
final FutureProvider<bool> reverseModeUnlockedProvider =
    FutureProvider<bool>((Ref ref) async {
      final String userId =
          ref.watch(activeUserIdProvider) ?? kLocalGuestUserId;
      final Map<String, int> mastery =
          await ref.read(phraseRepositoryProvider).getMasteryMap(userId);
      final int eligible =
          mastery.values.where((int level) => level >= 3).length;
      return eligible >= 3;
    });

final FutureProvider<int> reverseEligiblePhraseCountProvider =
    FutureProvider<int>((Ref ref) async {
      final String userId =
          ref.watch(activeUserIdProvider) ?? kLocalGuestUserId;
      final Map<String, int> mastery =
          await ref.read(phraseRepositoryProvider).getMasteryMap(userId);
      return mastery.values.where((int level) => level >= 3).length;
    });
