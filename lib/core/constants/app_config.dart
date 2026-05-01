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
