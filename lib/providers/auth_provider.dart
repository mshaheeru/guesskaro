import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local/cache_service.dart';

/// Result after email sign-up tries to attach a usable session on device.
enum SignUpFlowResult {
  success,
  emailConfirmationRequired,
  noSession,
}

class AuthNotifier extends AsyncNotifier<User?> {
  final SupabaseClient _client = Supabase.instance.client;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  FutureOr<User?> build() {
    _authSubscription?.cancel();
    _authSubscription = _client.auth.onAuthStateChange.listen((
      AuthState event,
    ) {
      state = AsyncData(event.session?.user);
    });
    ref.onDispose(() => _authSubscription?.cancel());

    return _client.auth.currentUser;
  }

  Future<void> signInAsGuest() async {
    state = const AsyncLoading<User?>();
    state = await AsyncValue.guard<User?>(() async {
      final AuthResponse response = await _client.auth.signInAnonymously();
      return response.user ?? _client.auth.currentUser;
    });
  }

  /// Email/password sign-up.
  ///
  /// [SignUpFlowResult.emailConfirmationRequired] only when Supabase project has
  /// **Authentication → Providers → Email → Confirm email** enabled. Disable
  /// that toggle for immediate session here (clients cannot bypass it).
  Future<SignUpFlowResult> completeEmailSignUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading<User?>();

    try {
      final AuthResponse response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: <String, dynamic>{'display_name': displayName.trim()},
      );

      final Session? sess = response.session;
      User? user = sess?.user ?? response.user;

      if (sess != null && user != null) {
        state = AsyncData<User?>(user);
        return SignUpFlowResult.success;
      }

      try {
        final AuthResponse signedIn = await _client.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );
        user =
            signedIn.session?.user ??
            signedIn.user ??
            _client.auth.currentUser;
        if (user != null && _client.auth.currentSession != null) {
          state = AsyncData<User?>(user);
          return SignUpFlowResult.success;
        }
      } on AuthException catch (e) {
        final String msg = e.message.toLowerCase();
        final User? cur = _client.auth.currentUser;
        state = AsyncData<User?>(cur);
        if (msg.contains('email') && msg.contains('confirm')) {
          return SignUpFlowResult.emailConfirmationRequired;
        }
        return SignUpFlowResult.noSession;
      }

      state = AsyncData<User?>(_client.auth.currentUser);
      return SignUpFlowResult.noSession;
    } on AuthException {
      final User? cur = _client.auth.currentUser;
      state = AsyncData<User?>(cur);
      rethrow;
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading<User?>();
    state = await AsyncValue.guard<User?>(() async {
      final AuthResponse response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response.user ??
          response.session?.user ??
          _client.auth.currentUser;
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading<User?>();
    state = await AsyncValue.guard<User?>(() async {
      await _client.auth.signInWithOAuth(OAuthProvider.google);
      return _client.auth.currentUser;
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading<User?>();
    state = await AsyncValue.guard<User?>(() async {
      final CacheService cacheService = ref.read(cacheServiceProvider);
      await cacheService.init();
      await cacheService.clearAll();
      await _client.auth.signOut();
      return null;
    });
  }
}

final AsyncNotifierProvider<AuthNotifier, User?> authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

final Provider<User?> currentUserProvider = Provider<User?>(
  (Ref ref) => ref.watch(authNotifierProvider).valueOrNull,
);

final Provider<bool> isLoggedInProvider = Provider<bool>(
  (Ref ref) => ref.watch(currentUserProvider) != null,
);
