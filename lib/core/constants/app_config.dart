/// Feature flags — Supabase auth code stays in tree; gate with [kAuthEnabled] only.
library;

/// Set to `true` when you want anonymous / Google auth again.
const bool kAuthEnabled = true;

/// Stable id for local-only Hive / guest profile (not `auth.users`).
const String kLocalGuestUserId = 'local_guest';

/// Dev/testing: wipes Hive phrase cache once at startup so next phrase fetch hits Supabase.
///
/// `flutter run --dart-define=CLEAR_PHRASE_CACHE=true`
///
/// Omit or `false` for normal 24h cache behaviour.
const bool kClearPhraseCacheOnLaunch =
    bool.fromEnvironment('CLEAR_PHRASE_CACHE', defaultValue: false);

/// Minimum interval before local phrase cache is considered stale and Supabase refetch runs.
///
/// • `24` default — refetch roughly once per day.
/// • `0` — always prefer network when online (heavy; dev only).
/// • `flutter run --dart-define=PHRASE_CACHE_TTL_HOURS=1`
const int kPhraseCacheTtlHours = int.fromEnvironment(
  'PHRASE_CACHE_TTL_HOURS',
  defaultValue: 24,
);
