import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/app_config.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/local_profile_repository.dart';
import '../data/repositories/profile_repository.dart';
import 'auth_provider.dart';
import 'local_guest_provider.dart';

String _displayNameFromUser(User user) {
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

Future<ProfileModel?> _bootstrapOrFetchRemote(
  ProfileRepository repo,
  User user,
) async {
  ProfileModel? profile = await repo.fetchProfile(user.id);
  if (profile != null) {
    return profile;
  }
  try {
    return await repo.createProfile(
      userId: user.id,
      displayName: _displayNameFromUser(user),
      avatarIndex: 0,
      showOnLeaderboard: true,
    );
  } catch (_) {
    return null;
  }
}

class ProfileNotifier extends AsyncNotifier<ProfileModel?> {
  ProfileRepository get _profileRepository =>
      ref.read(profileRepositoryProvider);
  LocalProfileRepository get _localProfileRepository =>
      ref.read(localProfileRepositoryProvider);

  @override
  FutureOr<ProfileModel?> build() async {
    if (!kAuthEnabled) {
      final AsyncValue<bool> reg = ref.watch(localGuestRegisteredProvider);
      if (reg.isLoading || reg.hasError) return null;
      if (reg.value != true) return null;
      return _localProfileRepository.loadProfile();
    }

    final User? user = ref.watch(currentUserProvider);
    if (user != null) {
      return _bootstrapOrFetchRemote(_profileRepository, user);
    }

    final AsyncValue<bool> registered = ref.watch(localGuestRegisteredProvider);
    if (registered.isLoading || registered.hasError) return null;
    if (registered.value != true) return null;
    return _localProfileRepository.loadProfile();
  }

  Future<void> refreshProfile() async {
    if (!kAuthEnabled) {
      state = const AsyncLoading<ProfileModel?>();
      state = await AsyncValue.guard<ProfileModel?>(
        _localProfileRepository.loadProfile,
      );
      return;
    }

    final User? user = ref.read(currentUserProvider);
    if (user != null) {
      state = const AsyncLoading<ProfileModel?>();
      state = await AsyncValue.guard<ProfileModel?>(() {
        return _bootstrapOrFetchRemote(_profileRepository, user);
      });
      return;
    }

    if (ref.read(localGuestRegisteredProvider).valueOrNull == true) {
      state = const AsyncLoading<ProfileModel?>();
      state = await AsyncValue.guard<ProfileModel?>(
        _localProfileRepository.loadProfile,
      );
      return;
    }

    state = const AsyncData<ProfileModel?>(null);
  }

  Future<void> awardXpAndCoins({required int xp, required int coins}) async {
    final previous = state.valueOrNull;
    if (!kAuthEnabled) {
      final ProfileModel updated = await _localProfileRepository.addXpAndCoins(
        xp: xp,
        coins: coins,
      );
      if (previous != null && updated.level > previous.level) {
        ref.read(levelUpProvider.notifier).state = true;
      }
      state = AsyncData<ProfileModel?>(updated);
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (ref.read(localGuestRegisteredProvider).valueOrNull != true) {
        throw Exception('No active profile.');
      }
      final ProfileModel updated = await _localProfileRepository.addXpAndCoins(
        xp: xp,
        coins: coins,
      );
      if (previous != null && updated.level > previous.level) {
        ref.read(levelUpProvider.notifier).state = true;
      }
      state = AsyncData<ProfileModel?>(updated);
      return;
    }

    final ProfileModel updated = await _profileRepository.addXpAndCoins(
      userId: user.id,
      xp: xp,
      coins: coins,
    );

    if (previous != null && updated.level > previous.level) {
      ref.read(levelUpProvider.notifier).state = true;
    }

    state = AsyncData<ProfileModel?>(updated);
  }

  Future<void> spendCoins(int amount) async {
    if (!kAuthEnabled) {
      final bool ok = await _localProfileRepository.deductCoins(amount);
      if (!ok) {
        throw Exception('Insufficient coins.');
      }
      await refreshProfile();
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      final bool ok = await _localProfileRepository.deductCoins(amount);
      if (!ok) {
        throw Exception('Insufficient coins.');
      }
      await refreshProfile();
      return;
    }

    final bool ok = await _profileRepository.deductCoins(
      userId: user.id,
      amount: amount,
    );
    if (!ok) {
      throw Exception('Insufficient coins.');
    }
    await refreshProfile();
  }

  Future<void> syncDayStreak() async {
    if (!kAuthEnabled) {
      final ProfileModel updated =
          await _localProfileRepository.updateDayStreak();
      state = AsyncData<ProfileModel?>(updated);
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (ref.read(localGuestRegisteredProvider).valueOrNull != true) return;
      final ProfileModel updated =
          await _localProfileRepository.updateDayStreak();
      state = AsyncData<ProfileModel?>(updated);
      return;
    }
    final ProfileModel updated = await _profileRepository.updateDayStreak(
      user.id,
    );
    state = AsyncData<ProfileModel?>(updated);
  }

  Future<void> updateOfflineDisplayName(String name) async {
    final ProfileModel? current = await _localProfileRepository.loadProfile();
    if (current == null) return;
    await _localProfileRepository.overwriteProfile(
      current.copyWith(displayName: name.trim()),
    );
    await refreshProfile();
  }

  Future<void> updateOfflineAvatar(int index) async {
    final ProfileModel? current = await _localProfileRepository.loadProfile();
    if (current == null) return;
    await _localProfileRepository.overwriteProfile(
      current.copyWith(avatarIndex: index),
    );
    await refreshProfile();
  }

  /// Ensures remotely signed-in player has profiles row before session save awards XP.
  Future<void> bootstrapRemoteProfileIfMissing() async {
    if (!kAuthEnabled) return;
    final User? user = ref.read(currentUserProvider);
    if (user == null) return;
    ProfileModel? p = state.valueOrNull;
    p ??= await _profileRepository.fetchProfile(user.id);
    if (p != null) {
      state = AsyncData<ProfileModel?>(p);
      return;
    }
    p = await _bootstrapOrFetchRemote(_profileRepository, user);
    state = AsyncData<ProfileModel?>(p);
  }

  Future<void> setInputMode(String inputMode) async {
    if (!kAuthEnabled) {
      final ProfileModel updated = await _localProfileRepository
          .updateInputMode(inputMode);
      state = AsyncData<ProfileModel?>(updated);
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (ref.read(localGuestRegisteredProvider).valueOrNull != true) return;
      final ProfileModel updated = await _localProfileRepository
          .updateInputMode(inputMode);
      state = AsyncData<ProfileModel?>(updated);
      return;
    }
    final ProfileModel updated = await _profileRepository.updateInputMode(
      userId: user.id,
      inputMode: inputMode,
    );
    state = AsyncData<ProfileModel?>(updated);
  }
}

final AsyncNotifierProvider<ProfileNotifier, ProfileModel?>
profileNotifierProvider = AsyncNotifierProvider<ProfileNotifier, ProfileModel?>(
  ProfileNotifier.new,
);

final StateProvider<bool> levelUpProvider = StateProvider<bool>(
  (Ref ref) => false,
);

final Provider<int> currentCoinsProvider = Provider<int>((Ref ref) {
  return ref.watch(profileNotifierProvider).valueOrNull?.coins ?? 0;
});
