import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_config.dart';
import '../data/models/leaderboard_entry_model.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/local_profile_repository.dart';
import '../data/repositories/profile_repository.dart';
import 'profile_provider.dart';

final FutureProvider<List<LeaderboardEntryModel>> leaderboardProvider =
    FutureProvider<List<LeaderboardEntryModel>>((Ref ref) async {
      if (kAuthEnabled) {
        return ref
            .read(profileRepositoryProvider)
            .fetchTopLeaderboard(limit: 50);
      }

      final LocalProfileRepository localRepo = ref.read(
        localProfileRepositoryProvider,
      );
      final ProfileModel? local = await localRepo.loadProfile();
      if (local == null) {
        return <LeaderboardEntryModel>[];
      }
      return <LeaderboardEntryModel>[
        LeaderboardEntryModel(
          userId: local.id,
          displayName: local.displayName,
          streak: local.longestStreak,
          coins: local.coins,
          rank: 1,
        ),
      ];
    });

final Provider<LeaderboardEntryModel?> currentUserLeaderboardEntryProvider =
    Provider<LeaderboardEntryModel?>((Ref ref) {
      final List<LeaderboardEntryModel> rows =
          ref.watch(leaderboardProvider).valueOrNull ??
          const <LeaderboardEntryModel>[];
      final ProfileModel? profile =
          ref.watch(profileNotifierProvider).valueOrNull;
      if (profile == null) return null;
      for (final LeaderboardEntryModel row in rows) {
        if (row.userId == profile.id) {
          return row;
        }
      }
      return null;
    });
