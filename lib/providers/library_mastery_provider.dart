import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_config.dart';
import '../core/constants/mastery_constants.dart';
import '../data/models/library_mastery_summary.dart';
import '../data/models/phrase_model.dart';
import '../data/repositories/phrase_repository.dart';
import 'session_user_provider.dart';

export '../data/models/library_mastery_summary.dart';

final FutureProvider<LibraryMasterySummary> libraryMasterySummaryProvider =
    FutureProvider<LibraryMasterySummary>((Ref ref) async {
      final String userId =
          ref.watch(activeUserIdProvider) ?? kLocalGuestUserId;
      final PhraseRepository repo = ref.watch(phraseRepositoryProvider);
      final List<PhraseModel> phrases = await repo.fetchAllPhrases();
      final Map<String, int> mastery = await repo.getMasteryMap(userId);
      final int total = phrases.length;

      int mastered = 0;
      int learning = 0;
      for (final PhraseModel phrase in phrases) {
        final int level = mastery[phrase.id] ?? 0;
        if (MasteryConstants.isMastered(level)) {
          mastered++;
        } else if (level >= 1) {
          learning++;
        }
      }

      final int tracked = mastery.length;
      final int unseen = (total - tracked).clamp(0, total);

      return LibraryMasterySummary(
        totalPhrases: total,
        masteredCount: mastered,
        learningCount: learning,
        unseenCount: unseen,
      );
    });
