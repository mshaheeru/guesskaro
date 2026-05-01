import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_config.dart';
import '../../data/local/local_player_prefs.dart';
import '../../screens/auth/sign_in_screen.dart';
import '../../screens/auth/sign_up_screen.dart';
import '../../screens/game/photo_card_screen.dart';
import '../../screens/game/reveal_card_screen.dart';
import '../../screens/game/session_summary_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/leaderboard/leaderboard_screen.dart';
import '../../screens/library/phrase_library_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/welcome/welcome_screen.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'root',
        builder: (_, __) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        name: 'sign-in',
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        name: 'sign-up',
        builder: (_, __) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboard',
        builder: (_, __) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/game/photo-card',
        name: 'photo-card',
        builder: (_, __) => const PhotoCardScreen(),
      ),
      GoRoute(
        path: '/game/reveal-card',
        name: 'reveal-card',
        builder: (_, __) => const RevealCardScreen(),
      ),
      GoRoute(
        path: '/game/summary',
        name: 'summary',
        builder: (_, __) => const SessionSummaryScreen(),
      ),
      GoRoute(
        path: '/library',
        name: 'library',
        builder: (_, __) => const PhraseLibraryScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (_, __) => const SettingsScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) async {
      if (!kAuthEnabled &&
          (state.matchedLocation == '/sign-in' ||
              state.matchedLocation == '/sign-up')) {
        return '/welcome';
      }

      if (state.matchedLocation != '/') {
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      final guestReady = prefs.getBool(LocalPlayerPrefs.keyGuestReady) ?? false;

      if (kAuthEnabled) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) return '/home';
        if (guestReady) return '/home';
        if (!hasSeenOnboarding) return '/onboarding';
        return '/sign-in';
      }

      if (guestReady) return '/home';
      if (!hasSeenOnboarding) return '/onboarding';
      return '/welcome';
    },
  );
}
