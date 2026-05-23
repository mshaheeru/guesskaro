import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_config.dart';
import '../core/constants/leaderboard_metric.dart';
import '../data/models/leaderboard_entry_model.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/local_profile_repository.dart';
import '../data/repositories/profile_repository.dart';
import 'auth_provider.dart';

/// Active leaderboard tab (Streak / Daily streak / Total score).
final leaderboardMetricProvider = StateProvider<LeaderboardMetric>(
  (Ref ref) => LeaderboardMetric.sessionStreak,
);

final leaderboardScreenDataProvider =
    FutureProvider<LeaderboardScreenData>((Ref ref) async {
  final LeaderboardMetric metric = ref.watch(leaderboardMetricProvider);

  if (kAuthEnabled) {
    final String? uid = ref.watch(currentUserProvider)?.id;
    return ref
        .read(profileRepositoryProvider)
        .fetchLeaderboardScreenData(signedInUserId: uid, metric: metric);
  }

  final LocalProfileRepository localRepo = ref.read(
    localProfileRepositoryProvider,
  );
  final ProfileModel? local = await localRepo.loadProfile();
  if (local == null) {
    return const LeaderboardScreenData(top: <LeaderboardEntryModel>[], you: null);
  }
  final LeaderboardEntryModel solo = LeaderboardEntryModel(
    userId: local.id,
    displayName: local.displayName,
    xp: local.xp,
    streak: local.longestStreak,
    dayStreak: local.dayStreak,
    coins: local.coins,
    rank: 1,
  );
  return LeaderboardScreenData(top: <LeaderboardEntryModel>[solo], you: solo);
});
