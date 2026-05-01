import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/local/local_player_prefs.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/local_guest_provider.dart';
import '../../providers/profile_provider.dart';

/// After signing in with Supabase, stop treating device as `/welcome` guest.
Future<void> clearGuestPlayPrefs(WidgetRef ref) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(LocalPlayerPrefs.keyGuestReady, false);
  ref.invalidate(localGuestRegisteredProvider);
}

String resolvedDisplayNameForProfile(User user, String preferredDisplayName) {
  final String trimmed = preferredDisplayName.trim();
  if (trimmed.isNotEmpty) return trimmed;
  final Map<String, dynamic>? m = user.userMetadata;
  if (m != null) {
    for (final String key in <String>['display_name', 'full_name', 'name']) {
      final Object? raw = m[key];
      if (raw is String && raw.trim().isNotEmpty) {
        return raw.trim();
      }
    }
  }
  final String? email = user.email;
  if (email != null && email.contains('@')) {
    return email.split('@').first;
  }
  return 'Player';
}

/// Ensures Supabase profiles row ranks on leaderboard (never for offline guests).
Future<void> ensureRegisteredLeaderboardProfile(
  WidgetRef ref, {
  required String preferredDisplayName,
  required int avatarIndex,
}) async {
  final User? user = ref.read(currentUserProvider);
  if (user == null) return;

  final ProfileRepository repo = ref.read(profileRepositoryProvider);
  ProfileModel? existing = await repo.fetchProfile(user.id);

  if (existing == null) {
    final String name =
        preferredDisplayName.trim().isNotEmpty
            ? preferredDisplayName.trim()
            : resolvedDisplayNameForProfile(user, '');
    try {
      await repo.createProfile(
        userId: user.id,
        displayName: name,
        avatarIndex: avatarIndex.clamp(0, 99),
        showOnLeaderboard: true,
      );
    } catch (_) {
      existing = await repo.fetchProfile(user.id);
    }
  }

  existing ??= await repo.fetchProfile(user.id);
  if (existing == null) return;

  ProfileModel updated = existing;
  bool touched = false;
  if (!existing.showOnLeaderboard) {
    updated = updated.copyWith(showOnLeaderboard: true);
    touched = true;
  }

  final int avatar = avatarIndex.clamp(0, 99);
  if (preferredDisplayName.trim().isNotEmpty &&
      (updated.displayName != preferredDisplayName.trim() ||
          updated.avatarIndex != avatar)) {
    updated = updated.copyWith(
      displayName: preferredDisplayName.trim(),
      avatarIndex: avatar,
    );
    touched = true;
  }

  if (touched) {
    await repo.updateProfile(updated);
  }
}

Future<void> goHomeAfterAccountAuth(
  WidgetRef ref,
  GoRouter router, {
  required String preferredDisplayName,
  required int avatarIndex,
}) async {
  await clearGuestPlayPrefs(ref);
  await ensureRegisteredLeaderboardProfile(
    ref,
    preferredDisplayName: preferredDisplayName,
    avatarIndex: avatarIndex,
  );
  await ref.read(profileNotifierProvider.notifier).refreshProfile();
  ref.invalidate(leaderboardScreenDataProvider);
  router.go('/home');
}
