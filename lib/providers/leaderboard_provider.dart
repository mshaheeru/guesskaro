import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_config.dart';
import '../data/models/leaderboard_entry_model.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/local_profile_repository.dart';
import '../data/repositories/profile_repository.dart';
import 'auth_provider.dart';

final FutureProvider<LeaderboardScreenData> leaderboardScreenDataProvider =
    FutureProvider<LeaderboardScreenData>((Ref ref) async {
      if (kAuthEnabled) {
        final String? uid = ref.watch(currentUserProvider)?.id;
        return ref
            .read(profileRepositoryProvider)
            .fetchLeaderboardScreenData(signedInUserId: uid);
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
        coins: local.coins,
        rank: 1,
      );
      return LeaderboardScreenData(top: <LeaderboardEntryModel>[solo], you: solo);
    });
